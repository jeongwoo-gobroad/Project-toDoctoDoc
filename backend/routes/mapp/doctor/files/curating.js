const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../../models/User");
const returnResponse = require("../../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, generateRefreshToken, getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const returnLongLatOfAddress = require("../../../../middleware/getcoordinate");
const router = express.Router();

const User = mongoose.model("User", UserSchema);
const Doctor = require("../../../../models/Doctor");
const nearbyPatientCurate = require("../../../../middleware/nearCurate");
const Curate = require("../../../../models/Curate");
const Comment = require("../../../../models/Comment");
const sendCuratePushNotification = require("../../push/curatePush");

router.get(["/"], 
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const user = await getTokenInformation(req, res);
            const km = req.query.radius;

            const docInfo = await Doctor.findById(user.userid);
            
            const aroundPatientList = await nearbyPatientCurate(docInfo.address.longitude, docInfo.address.latitude, km);

            // console.log(docInfo.curatesRead);

            set = new Set(docInfo.curatesRead);

            for (let index of aroundPatientList) {
                if (set.has(index._id.toString())) {
                    // console.log("true");
                    index.isRead = true;
                } else {
                    index.isRead = false;
                }
            }

            res.status(200).json(returnResponse(false, "doctor_curating_success", aroundPatientList));

            return;
        } catch (error) {
            console.error(error, "error at doctor_curating");

            res.status(403).json(returnResponse(true, "error_at_doctor_curating", "-"))

            return;
        }
    }
);

router.get(["/details/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const curate = await Curate.findById(req.params.id).populate(
                [
                    {path: 'posts'},
                    {path: 'ai_chats'},
                    {path: 'comments', populate: {path: 'doctor', select: 'name address phone email'}}
                ]
            );

            if (curate) {
                const user = await getTokenInformation(req, res);
                const docInfo = await Doctor.findById(user.userid);
                const set = new Set(docInfo.curatesRead);
                if (!set.has(req.params.id)) {
                    await Doctor.findByIdAndUpdate(user.userid, {
                        $push: {curatesRead: req.params.id}
                    });
                    // console.log("wow");
                }

                res.status(200).json(returnResponse(false, "doctor_curating_details_success", curate));

                return;
            } else {
                res.status(401).json(returnResponse(true, "noSuchCurateID", ""));

                return;
            }   

            return;
        } catch (error) {
            console.error(error, "error at doctor_curating_details");

            res.status(403).json(returnResponse(true, "error_at_doctor_curating_details", "-"))

            return;
        }
    }
);

router.post(["/comment/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const user = await getTokenInformation(req, res);
            const {comment} = req.body;
            const curate = await Curate.findById(req.params.id).populate('comments', 'doctor').populate('user', 'deviceIds');

            if (curate && comment.length > 0) {
                for (const c of curate.comments) {
                    if (c.doctor == user.userid) {
                        res.status(402).json(returnResponse(true, "already_comment_exists", "-"));

                        return;
                    }
                }

                const newComment = await Comment.create({
                    doctor: user.userid,
                    content: comment,
                    originalID: req.params.id,
                });

                curate.comments.push(newComment._id);
                curate.isNotRead = true;

                await Doctor.findByIdAndUpdate(user.userid, {
                    $push: {commentsWritten: newComment._id}
                });

                await curate.save();

                await sendCuratePushNotification(curate.user.deviceIds, {title: "큐레이팅 요청 응답", body: newComment})

                res.status(200).json(returnResponse(false, "doctor_curating_comment_success", "-"));

                return;
            } else {
                res.status(401).json(returnResponse(true, "noSuchCurateIDorTooShortComment", "-"));

                return;
            }   

            return;
        } catch (error) {
            console.error(error, "error at doctor_curating_comment");

            res.status(403).json(returnResponse(true, "error_at_doctor_curating_comment", "-"))

            return;
        }
    }
);

router.patch(["/commentModify/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const {comment} = req.body;
            const user = await getTokenInformation(req, res);
            const prev = await Comment.findById(req.params.id);

            if (prev.doctor != user.userid) {
                res.status(401).json(returnResponse(true, "notYourComment", "-"));

                return;
            }

            prev.content = comment;

            await prev.save();

            res.status(200).json(returnResponse(false, "successfullyEditedComment", "-"));

            return;
        } catch (error) {
            console.error(error, "error at doctor_comment_edit");

            res.status(403).json(returnResponse(true, "error at doctor_comment_edit", "-"))

            return;
        }
    }
);

router.delete(["/commentModify/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const user = await getTokenInformation(req, res);
            const prev = await Comment.findById(req.params.id);

            if (prev.doctor != user.userid) {
                res.status(401).json(returnResponse(true, "notYourComment", "-"));

                return;
            }
            await Curate.findByIdAndUpdate(prev.originalID, {
                $pull: {comments: req.params.id}
            });
            await Doctor.findByIdAndUpdate(user.userid, {
                $pull: {
                    commentsWritten: req.params.id
                }
            });
            await Comment.findByIdAndDelete(req.params.id);

            res.status(200).json(returnResponse(false, "successfullyDeletedComment", "-"));

            return;
        } catch (error) {
            console.error(error, "error at doctor_comment_delete");

            res.status(403).json(returnResponse(true, "error at doctor_comment_delete", "-"))

            return;
        }
    }
);

module.exports = router;