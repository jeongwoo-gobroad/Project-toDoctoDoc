require("dotenv").config;
const express = require("express");
const mongoose = require("mongoose");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const { getTokenInformation } = require("../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn, ifPremiumThenProceed } = require("../checkingMiddleWare");
const router = express.Router();

const User = mongoose.model("User", UserSchema);
const { ifDailyCurateNotExceededThenProceed } = require("../limitMiddleWare");
const Curate = require("../../../models/Curate");
const Comment = require("../../../models/Comment");
const Chat = require("../../../models/Chat");
const Appointment = require("../../../models/Appointment");
const Psychiatry = require("../../../models/Psychiatry");

router.get(["/appointment/get/:cid"],
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const chat = await Chat.findById(req.params.cid).populate({
                path: 'appointment',
                populate: {
                    path: 'doctor',
                    select: 'name',
                }
            });

            if (chat.user != user.userid) {
                res.status(401).json(returnResponse(true, "notYourChat", "-"));

                return;
            }

            const psy = await Psychiatry.findById(chat.doctor.myPsyID);

            res.status(200).json(returnResponse(false, "appointment", {appointment: chat.appointment, psy: psy}));

            return;
        } catch (error) {
            console.error(error, "errorAtUserAppointmentGET");

            res.status(403).json(returnResponse(true, "errorAtUserAppointmentGET", "-"));

            return;
        }
    }
);

router.get(["/appointment/getWithAppid/:appid"],
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const appointment = await Appointment.findById(req.params.appid).populate('doctor', 'isPremiumPsy myPsyID');
            let psy = null;

            if (appointment.user != user.userid) {
                res.status(402).json(returnResponse(true, "notYourAppointment", "-"));

                return;
            }

            psy = await Psychiatry.findById(appointment.doctor.myPsyID);

            res.status(200).json(returnResponse(false, "appointment", {appointment: appointment, psy: psy}));

            return;
        } catch (error) {
            console.error(error, "errorAtUserAppointmentGETwithAppid");

            res.status(403).json(returnResponse(true, "errorAtUserAppointmentGETwithAppid", "-"));

            return;
        }
    }
);

router.post(["/appointment/approve"],
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const {appid} = req.body;

        try {
            const appointment = await Appointment.findById(appid);

            if (!appointment) {
                res.status(401).json(returnResponse(true, "noSuchAppointment", "-"));

                return;
            }

            if (appointment.user != user.userid) {
                res.status(402).json(returnResponse(true, "notOwner", "-"));

                return;
            }

            appointment.isAppointmentApproved = true;

            await appointment.save();

            res.status(200).json(returnResponse(false, "appointmentApprovedByUser", "-"));

            return;
        } catch (error) {
            console.error(error, "errorAtUserAppointmentApprove");

            res.status(403).json(returnResponse(true, "errorAtUserAppointmentApprove", "-"));

            return;
        }
    }
);

router.get(["/appointment/list"],
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const usr = await User.findById(user.userid).populate({
                path: 'appointments',
                populate: {
                    path: 'doctor',
                    select: 'name'
                }
            });

            // console.log(usr.appointments);

            const appointments = usr.appointments;

            res.status(200).json(returnResponse(false, "appointments", appointments));
        } catch (error) {
            console.error(error, "errorAtUserAppointmentListGET");

            res.status(403).json(returnResponse(true, "errorAtUserAppointmentListGET", "-"));

            return;
        }
    }
);

router.post(["/appointment/review"],
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const {appid, rating, content} = req.body;

        try {
            const appointment = await Appointment.findById(appid);

            if (!appointment) {
                res.status(401).json(returnResponse(true, "noSuchAppointment", "-"));

                return;
            }

            if (appointment.user != user.userid || !appointment.hasAppointmentDone) {
                res.status(402).json(returnResponse(true, "notYourAppointmentOrAppointmentIsNotDoneYet", "-"));

                return;
            }

            if (rating < 0 || rating > 2) {
                rating = 2;
            }

            appointment.feedback = {
                rating: rating,
                content: content,
            }
            appointment.hasFeedbackDone = true;

            await appointment.save();

            res.status(200).json(returnResponse(false, "savedAppointmentReview", "-"));

            return;
        } catch (error) {
            console.error(error, "errorAtUserAppointmentReview");

            res.status(403).json(returnResponse(true, "errorAtUserAppointmentReview", "-"));

            return;
        }
    }
);

module.exports = router;