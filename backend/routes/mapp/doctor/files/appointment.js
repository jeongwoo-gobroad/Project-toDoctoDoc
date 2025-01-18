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

router.get(["/list"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const doctor = await getTokenInformation(req, res);

        try {
            const information = await Doctor.findById(doctor.userid).populate('appointments').populate('user', 'usernick');

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

router.post(["/set"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const doctor = await getTokenInformation(req, res);
        const {uid, time} = req.body; // time 객체는 GMT 기준으로 1995-12-17T03:24:00 의 형태로 나타내야 함.

        try {
            const appointment = await Appointment.create({
                user: uid,
                doctor: doctor.userid,
                appointmentTime: new Date(time)
            });

            await Doctor.findByIdAndUpdate(doctor.userid, {
                $push: {appointments: appointment._id}
            });

            await User.findByIdAndUpdate(uid, {
                $push: {appointments: appointment._id}
            });

            res.status(200).json(returnResponse(false, "setAppointment", "-"));

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
        const doctor = await getTokenInformation(req, res);

        try {
            
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

        try {
            
        } catch (error) {
            console.error(error, "error at /appointment/set DELETE");

            res.status(403).json(returnResponse(true, "errorAtAppointmentDeleting", "-"));

            return;
        }
    }
);

module.exports = router;