const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../../models/User");
const returnResponse = require("../../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, generateRefreshToken, getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn, ifPremiumThenProceed, isDoctorThenProceed } = require("../../checkingMiddleWare");
const returnLongLatOfAddress = require("../../../../middleware/getcoordinate");
const router = express.Router();
const Doctor = require("../../../../models/Doctor");
const Chat = require("../../../../models/Chat");
const Premium_Psychiatry = require("../../../../models/Premium_Psychiatry");
const User = mongoose.model("User", UserSchema);

router.post(["/appointment"], 
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const {chatid} = req.body;

            const chat = await Chat.findById(chatid);

            if (!chat || chat.doctor != user.userid) {
                res.status(401).json(returnResponse(true, "notYourAppointmentOrNoSuchChat", "-"));

                return;
            }

            chat.hasAppointmentDone = true;

            await chat.save();

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

            const psy = await Premium_Psychiatry.findById(doctor.myPsyID).populate('reviews', '-user');

            if (!psy) {
                res.status(401).json(returnResponse(true, "noSuchPsy", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "returnedReviewList", psy));            

            return;
        } catch (error) {
            console.error(error, "errorAtDoctorListing");

            res.status(403).json(returnResponse(true, "errorAtDoctorListing", "-"));

            return;
        }
    }
);

module.exports = router;