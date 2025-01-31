const express = require("express");
const { checkIfLoggedIn } = require("../checkingMiddleWare");
const { getTokenInformation } = require("../../auth/jwt");
const UserSchema = require("../../../models/User");
const { default: mongoose } = require("mongoose");
const returnResponse = require("../standardResponseJSON");
const router = express.Router();
const User = mongoose.model('User', UserSchema);

router.get(["/query"], 
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const ack = await User.findById(user.userid);

            res.status(200).json(returnResponse(false, "queryLimit", {
                query: 10, 
                userTotal: ack.limits.dailyRequestCount,
                userDate: ack.limits.dailyRequestDate,
            }));

            return;
        } catch (error) {
            console.error(error, "errorAtQueryLimitCheck");

            res.status(403).json(returnResponse(true, "errorAtQueryLimitCheck", "-"));

            return;
        }
    }
);

router.get(["/chats"], 
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const ack = await User.findById(user.userid);

            res.status(200).json(returnResponse(false, "queryLimit", {
                chats: 50, 
                userTotal: ack.limits.dailyChatCount,
                userDate: ack.limits.dailyChatDate
            }));

            return;
        } catch (error) {
            console.error(error, "errorAtChatLimitCheck");

            res.status(403).json(returnResponse(true, "errorAtChatLimitCheck", "-"));

            return;
        }
    }
);

module.exports = router;