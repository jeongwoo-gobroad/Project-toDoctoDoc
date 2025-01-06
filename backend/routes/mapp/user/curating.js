require("dotenv").config;
const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, getTokenInformation } = require("../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn } = require("../checkingMiddleWare");
const { route } = require("../main");
const returnLongLatOfAddress = require("../../../middleware/getcoordinate");
const router = express.Router();
const Premium_Psychiatry = require("../../../models/Premium_Psychiatry");

const User = mongoose.model("User", UserSchema);
const Chat = require("../../../models/Chat");
const AIChat = require("../../../models/AIChat");
const returnListOfPsychiatry = require("../../../middleware/getListOfPsychiatry");
const topExposureForPremiumPsy = require("../../../middleware/sortByPremiumPsy");

router.get(["/around"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const radius = req.query.radius;
        const info = await getTokenInformation(req, res);

        try {
            const user = await User.findById(info.userid);

            if (user) {
                let list = await returnListOfPsychiatry(user.address.longitude, user.address.latitude, parseInt(radius) * 1000);

                list = await topExposureForPremiumPsy(list);

                res.status(200).json(returnResponse(false, "around-psy-list", {list: list}));
            } else {
                res.status(404).json(returnResponse(true, "noSuchUser", "-"));
            }

            return;
        } catch (error) {
            console.error(error);
            res.status(405).json(returnResponse(true, "errorAt/around", "-"));

            return;
        }
    }
);

module.exports = router;