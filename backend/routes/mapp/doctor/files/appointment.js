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

router.get(["/list"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const doctor = await getTokenInformation(req, res);

        try {
            
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

        try {
            
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