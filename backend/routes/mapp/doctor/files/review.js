const express = require("express");
const mongoose = require("mongoose");
const UserSchema = require("../../../../models/User");
const returnResponse = require("../../standardResponseJSON");
const { getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const router = express.Router();
const Doctor = require("../../../../models/Doctor");
const Chat = require("../../../../models/Chat");
const Psychiatry = require("../../../../models/Psychiatry");
const Appointment = require("../../../../models/Appointment");
const User = mongoose.model('User', UserSchema);

router.post(["/appointment"], 
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const { appid } = req.body;

            const appointment = await Appointment.findById(appid);

            if (!appointment || appointment.doctor != user.userid) {
                res.status(401).json(returnResponse(true, "notYourAppointmentOrNoSuchChat", "-"));

                return;
            }

            if (!(await User.findById(appointment.user)).visitedPsys.toString().includes(appointment.psyId)) {
                await User.findByIdAndUpdate(appointment.user, {
                    $push: {visitedPsys: appointment.psyId}
                });
            }

            res.status(200).json(returnResponse(false, "appointmentHasBeenDone", "-"));

            return;
        } catch (error) {
            console.error(error, "errorAtAppointment");

            res.status(403).json(returnResponse(true, "errorAtAppointment", "-"));

            return;
        }
    }
);

router.get(["/list"], 
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const doctor = await Doctor.findById(user.userid);

            if (!doctor) {
                res.status(401).json(returnResponse(true, "noSuchDoctor", "-"));

                return;
            }

            const psy = await Psychiatry.findById(doctor.myPsyID).populate('reviews', '-user');

            if (!psy) {
                res.status(401).json(returnResponse(true, "noSuchPsy", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "returnedReviewList", {isPremiumPsy: doctor.isPremiumPsy, reviews: psy.reviews}));            

            return;
        } catch (error) {
            console.error(error, "errorAtDoctorListing");

            res.status(403).json(returnResponse(true, "errorAtDoctorListing", "-"));

            return;
        }
    }
);

module.exports = router;