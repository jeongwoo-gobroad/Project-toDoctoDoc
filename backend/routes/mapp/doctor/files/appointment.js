const express = require("express");
const mongoose = require("mongoose");
const UserSchema = require("../../../../models/User");
const returnResponse = require("../../standardResponseJSON");
const { getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const returnLongLatOfAddress = require("../../../../middleware/getcoordinate");
const router = express.Router();

const User = mongoose.model("User", UserSchema);
const Doctor = require("../../../../models/Doctor");
const Appointment = require("../../../../models/Appointment");
const Chat = require("../../../../models/Chat");
const sendAppointmentDonePushNotification = require("../../push/appointmentDonePush");

router.get(["/list"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const doctor = await getTokenInformation(req, res);

        try {
            const information = await Doctor.findById(doctor.userid).populate({
                path: 'appointments',
                populate: {
                    path: 'user',
                    select: 'usernick'
                }
            });
            const appointment = information.appointments;

            res.status(200).json(returnResponse(false, "appointmentListForDoctor", appointment));

            return;
        } catch (error) {
            console.error(error, "error at /appointment/list GET");

            res.status(403).json(returnResponse(true, "errorAtAppointmentListing", "-"));

            return;
        }
    }
);

router.get(["/get/:appid"], 
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        // const doctor = await getTokenInformation(req, res);

        // console.log("Appointment get: ", req.params.appid);

        try {
            const appointment = await Appointment.findById(req.params.appid);

            if (!appointment) {
                res.status(201).json(returnResponse(false, "noSuchAppointment", "-"));

                return;
            } 

            res.status(200).json(returnResponse(false, "appointmentGet", appointment));

            return;
        } catch (error) {
            console.error(error, "error at /appointment/get GET");

            res.status(403).json(returnResponse(true, "errorAtAppointmentGetting", "-"));

            return;
        }
    }
);

router.get(["/getWithChatId/:cid"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const chat = await Chat.findById(req.params.cid).populate({
                path: 'appointment',
                populate: {
                    path: 'user',
                    select: 'usernick',
                }
            });

            if (chat.doctor != user.userid) {
                res.status(401).json(returnResponse(true, "notYourChat", "-"));

                return;
            }

            if (!chat.appointment) {
                res.status(201).json(returnResponse(true, "noAppointment", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "appointmentGet", chat.appointment));

            return;
        } catch (error) {
            console.error(error, "error at /appointment/getWithChatId GET");

            res.status(403).json(returnResponse(true, "errorAtAppointmentgetWithChatId", "-"));

            return;
        }
    }
);

router.post(["/set"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const doctor = await getTokenInformation(req, res);
        const {cid, uid, time} = req.body; // time 객체는 GMT 기준으로 1995-12-17T03:24:00 의 형태로 나타내야 함.

        // console.log("Appointment set: ", cid, uid, time);

        try {
            const appointment = await Appointment.create({
                user: uid,
                doctor: doctor.userid,
                appointmentTime: new Date(time),
                chatId: cid,
                psyId: (await Doctor.findById(doctor.userid)).myPsyID
            });

            await Doctor.findByIdAndUpdate(doctor.userid, {
                $push: {appointments: appointment._id}
            });

            await User.findByIdAndUpdate(uid, {
                $push: {appointments: appointment._id}
            });

            await Chat.findByIdAndUpdate(cid, {
                appointment: appointment._id
            });

            res.status(200).json(returnResponse(false, "setAppointment", appointment));

            return;
        } catch (error) {
            console.error(error, "error at /appointment/set POST");

            res.status(403).json(returnResponse(true, "errorAtAppointmentSetting", "-"));

            return;
        }
    }
);

router.patch(["/set"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const {appid, time} = req.body; // time 객체는 GMT 기준으로 1995-12-17T03:24:00 의 형태로 나타내야 함.

        // console.log("Appointment fix: ", appid, time);

        try {
            const appointment = await Appointment.findByIdAndUpdate(appid, {
                appointmentTime: time,
                appointmentEditedAt: Date.now(),
                isAppointmentApproved: false
            });

            res.status(200).json(returnResponse(false, "editedAppointment", "-"));

            return;
        } catch (error) {
            console.error(error, "error at /appointment/set PATCH");

            res.status(403).json(returnResponse(true, "errorAtAppointmentEditing", "-"));

            return;
        }
    }
);

router.delete(["/set"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const doctor = await getTokenInformation(req, res);
        const {cid, appid, uid} = req.body;

        // console.log("Appointment delete: ", appid);

        try {
            await Appointment.findByIdAndDelete(appid);
            await Doctor.findByIdAndUpdate(doctor.userid, {
                $pull: {appointments: appid}
            });
            await User.findByIdAndUpdate(uid, {
                $pull: {appointments: appid}
            });
            await Chat.findByIdAndUpdate(cid, {
                appointment: null
            });

            res.status(200).json(returnResponse(false, "deletedAppointment", "-"));

            return;
        } catch (error) {
            console.error(error, "error at /appointment/set DELETE");

            res.status(403).json(returnResponse(true, "errorAtAppointmentDeleting", "-"));

            return;
        }
    }
);

router.post(["/done"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const doctor = await getTokenInformation(req, res);
        const {appid} = req.body;

        try {
            const appointment = await Appointment.findById(appid).populate({
                path: 'user',
                select: 'deviceIds',
            }).populate({
                path: 'doctor',
                select: 'name',
            });

            if (!appointment) {
                res.status(401).json(returnResponse(true, "noSuchAppointment", "-"));

                return;
            }

            appointment.hasAppointmentDone = true;

            await appointment.save();

            if (!(await User.findById(appointment.user)).visitedPsys.toString().includes(appointment.psyId)) {
                await User.findByIdAndUpdate(appointment.user, {
                    $push: {visitedPsys: appointment.psyId}
                });
            }

            sendAppointmentDonePushNotification(appointment.user.deviceIds, 
                {
                    title: `오늘 ${appointment.doctor.name} 과의 상담은 어땠나요?`,
                    body: "오늘 상담의 피드백을 남겨주세요."
                }
            )

            res.status(200).json(returnResponse(false, "madeAppointmentDone", "-"));

            return;
        } catch (error) {
            console.error(error, "error at /appointment/done POST");

            res.status(403).json(returnResponse(true, "errorAtAppointmentDone", "-"));

            return;
        }
    }
);

module.exports = router;