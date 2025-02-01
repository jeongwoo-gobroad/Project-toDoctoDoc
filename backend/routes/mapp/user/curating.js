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
const User = mongoose.model("User", UserSchema);
const Chat = require("../../../models/Chat");
const AIChat = require("../../../models/AIChat");
const returnListOfPsychiatry = require("../../../middleware/getListOfPsychiatry");
const topExposureForPremiumPsy = require("../../../middleware/sortByPremiumPsy");
const Psychiatry = require("../../../models/Psychiatry");

router.get(["/around"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const radius = req.query.radius;
        let page = req.query.page;
        const info = await getTokenInformation(req, res);

        if (!req.query.page) {
            page = 1;
        }

        try {
            const user = await User.findById(info.userid);

            if (user) {
                let list = await returnListOfPsychiatry(user.address.longitude, user.address.latitude, parseInt(radius) * 1000, page);

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

router.get(["/info/:pid"],
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const psy = await Psychiatry.findById(req.params.pid);

            if (!psy) {
                res.status(401).json(returnResponse(true, "noSuchPsy", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "psyInfo", psy));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtPIDInfo", "-"));

            console.error(error, "errorAtInfoPID");

            return;
        }
    }
);

module.exports = router;