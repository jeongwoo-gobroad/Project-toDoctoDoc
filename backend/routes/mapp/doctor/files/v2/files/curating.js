const express = require('express');
const { checkIfLoggedIn, isDoctorThenProceed } = require('../../../../checkingMiddleWare');
const Doctor = require('../../../../../../models/Doctor');
const Curate = require('../../../../../../models/Curate');
const returnResponse = require('../../../../standardResponseJSON');
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

module.exports = router; 