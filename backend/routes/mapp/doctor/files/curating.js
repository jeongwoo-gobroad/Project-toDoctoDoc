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

router.get(["/"], 
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const user = await getTokenInformation(req, res);
            const km = req.query.radius;

            const docInfo = await Doctor.findById(user.userid);
            
            const aroundPatientList = await nearbyPatientCurate(docInfo.address.longitude, docInfo.address.latitude, km);

            res.status(200).json(returnResponse(false, "doctor_curating_success", aroundPatientList));

            return;
        } catch (error) {
            console.error(error, "error at doctor_curating");

            res.status(403).json(returnResponse(true, "error_at_doctor_curating", "-"))

            return;
        }
    }
);

module.exports = router;