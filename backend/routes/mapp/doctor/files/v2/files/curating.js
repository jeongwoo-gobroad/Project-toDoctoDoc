const express = require('express');
const { checkIfLoggedIn, isDoctorThenProceed } = require('../../../../checkingMiddleWare');
const Doctor = require('../../../../../../models/Doctor');
const Curate = require('../../../../../../models/Curate');
const returnResponse = require('../../../../standardResponseJSON');
const nearbyPatientCurateV2 = require('../../../../../../middleware/nearCurateV2');
const router = express.Router();

router.get(["/myReadList"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const {amount, pageNumber, sort} = req.query;

        try {
            const sortOrder = parseInt(sort);

            const doctor = await Doctor.findById(req.userid);
            const curate = [];

            for (const c of doctor.curatesRead) {
                let crt = null;
                if ((crt = await Curate.findById(c, "-deepCurate -posts -ai_chats -comments"))) {
                    curate.push(crt);
                }
            }

            if (sortOrder === 1) { // 오름차순이라면
                curate.sort((a, b) => {
                    return a.date - b.date;
                });
            } else { // 내림차순이라면
                curate.sort((a, b) => {
                    return b.date - a.date;
                });
            }

            const rtnVal = curate.slice((pageNumber - 1) * amount, pageNumber * amount);

            res.status(200).json(returnResponse(false, "doctorReadList", rtnVal));

            return;
        } catch (error) {
            console.error(error, "error at doctor_curating_myReadList");

            res.status(403).json(returnResponse(true, "error_at_doctor_curating_myReadList", "-"))

            return;
        }
    }
);

router.get(["/myCommentList"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const {amount, pageNumber, sort} = req.query;

        try {
            const sortOrder = parseInt(sort);

            const doctor = await Doctor.findById(req.userid).populate({
                path: 'commentsWritten'
            });

            if (sortOrder === 1) {
                doctor.commentsWritten.sort((a, b) => {
                    return a.date - b.date;
                });
            } else {
                doctor.commentsWritten.sort((a, b) => {
                    return b.date - a.date;
                });
            }

            const rtnVal = doctor.commentsWritten.slice((pageNumber - 1) * amount, pageNumber * amount);

            res.status(200).json(returnResponse(false, "doctorCommentList", rtnVal));

            return;
        } catch (error) {
            console.error(error, "error at doctor_curating_myCommentList");

            res.status(403).json(returnResponse(true, "error_at_doctor_curating_myCommentList", "-"))

            return;
        }
    }
);

router.get(["/curating"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const {radius, amount, pageNumber, sort} = req.query;

        try {
            const sortOrder = parseInt(sort);
            const doctor = await Doctor.findById(req.userid);
            const patients = await nearbyPatientCurateV2(doctor.address.longitude, doctor.address.latitude, radius);
            const trueLists = [];

            if (sortOrder === 1) {
                patients.sort((a, b) => {
                    return a.recentCurateDate - b.recentCurateDate;
                });
            } else {
                patients.sort((a, b) => {
                    return b.recentCurateDate - a.recentCurateDate;
                });
            }
            
            const set = new Set(doctor.curatesRead);

            for (const patient of patients) {
                if (set.has(patient.recentCurate.toString())) {
                    patient.isRead = true;
                } else {
                    patient.isRead = false;
                }

                const curate = await Curate.findById(patient.recentCurate);

                if (curate.isPublic) {
                    trueLists.push(patient);
                }
            }

            const rtnVal = trueLists.slice((pageNumber - 1) * amount, pageNumber * amount);

            res.status(200).json(returnResponse(false, "doctorCurateList", rtnVal));

            return;
        } catch (error) {
            console.error(error, "error at doctor_curating_curate");

            res.status(500).json(returnResponse(true, "error_at_doctor_curating_curate", "-"))

            return;
        }
    }
);

router.get(["/view/:cid"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const curate = await Curate.findById(req.params.cid).populate(
                [
                    {path: 'posts'},
                    {path: 'ai_chats'},
                    {path: 'comments', populate: {path: 'doctor', select: 'name address phone email'}}
                ]
            );

            if (!curate) {
                res.status(401).json(returnResponse(true, "noSuchCurateID", "-"));

                return;
            }

            const readables = new Set(curate.ifNotPublicOpenedTo);

            if (!curate.isPublic && !readables.has(req.userid)) {
                res.status(402).json(returnResponse(true, "notAllowedToView", "-"));

                return;
            }

            const docInfo = await Doctor.findById(req.userid);
            const set = new Set(docInfo.curatesRead);
            if (!set.has(req.params.id)) {
                await Doctor.findByIdAndUpdate(req.userid, {
                    $push: {curatesRead: req.params.id}
                });
                // console.log("wow");
            }

            res.status(200).json(returnResponse(false, "doctor_curating_details_success", curate));

            return;
        } catch (error) {
            console.error(error, "errorAtdoctorCuratingView");

            res.status(500).json(returnResponse(true, "errorAtdoctorCuratingView", "-"))

            return;
        }
    }
);

router.post(["/comment/:cid"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const {comment} = req.body;
            const curate = await Curate.findById(req.params.cid).populate('comments', 'doctor').populate('user', 'deviceIds');

            const readables = new Set(curate.ifNotPublicOpenedTo);

            if (curate && comment.length > 0) {
                if (!curate.isPublic && !readables.has(req.userid)) {
                    res.status(402).json(returnResponse(true, "notAllowedToView", "-"));
    
                    return;
                }

                for (const c of curate.comments) {
                    if (c.doctor == req.userid) {
                        res.status(403).json(returnResponse(true, "already_comment_exists", "-"));

                        return;
                    }
                }

                const newComment = await Comment.create({
                    doctor: req.userid,
                    content: comment,
                    originalID: req.params.cid,
                });

                curate.comments.push(newComment._id);
                curate.isNotRead = true;
                curate.date = Date.now();

                await Doctor.findByIdAndUpdate(req.userid, {
                    $push: {commentsWritten: newComment._id}
                });

                await curate.save();

                await sendCuratePushNotification(curate.user.deviceIds, {title: "큐레이팅 요청 응답", body: newComment})

                res.status(200).json(returnResponse(false, "doctor_curating_comment_success_v2", "-"));

                return;
            } else {
                res.status(401).json(returnResponse(true, "noSuchCurateIDorTooShortComment", "-"));

                return;
            }   
        } catch (error) {
            console.error(error, "error at doctor_curating_comment_v2");

            res.status(500).json(returnResponse(true, "error_at_doctor_curating_comment_v2", "-"))

            return;
        }
    }
);

module.exports = router; 