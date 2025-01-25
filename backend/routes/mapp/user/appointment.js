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

router.get(["/appointment/:cid"],
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const chat = await Chat.findById(cid).populate({
                path: 'appointment',
                populate: {
                    path: 'doctor',
                    select: 'name'
                }
            });

            if (chat.user != user.userid) {
                res.status(401).json(returnResponse(true, "notYourChat", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "appointment", chat.appointment));

            return;
        } catch (error) {
            console.error(error, "errorAtUserAppointmentGET");

            res.status(403).json(returnResponse(true, "errorAtUserAppointmentGET", "-"));

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

            const appointments = usr.appointments;

            res.status(200).json(returnResponse(false, "appointments", appointments));
        } catch (error) {
            console.error(error, "errorAtUserAppointmentListGET");

            res.status(403).json(returnResponse(true, "errorAtUserAppointmentListGET", "-"));

            return;
        }
    }
);

module.exports = router;