const express = require("express");
const mongoose = require("mongoose");
const UserSchema = require("../../../../models/User");
const returnResponse = require("../../standardResponseJSON");
const { getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const router = express.Router();
const Doctor = require("../../../../models/Doctor");
const Chat = require("../../../../models/Chat");

router.post(["/premiumify"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        
    }
);

module.exports = router;