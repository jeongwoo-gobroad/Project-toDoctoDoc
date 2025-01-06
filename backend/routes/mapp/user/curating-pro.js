require("dotenv").config;
const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, getTokenInformation } = require("../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn, ifPremiumThenProceed } = require("../checkingMiddleWare");
const { route } = require("../main");
const returnLongLatOfAddress = require("../../../middleware/getcoordinate");
const router = express.Router();
const Premium_Psychiatry = require("../../../models/Premium_Psychiatry");

const User = mongoose.model("User", UserSchema);
const Chat = require("../../../models/Chat");
const AIChat = require("../../../models/AIChat");
const returnListOfPsychiatry = require("../../../middleware/getListOfPsychiatry");
const topExposureForPremiumPsy = require("../../../middleware/sortByPremiumPsy");
const { ifDailyRequestNotExceededThenProceed } = require("../limitMiddleWare");
const Curate = require("../../../models/Curate");

router.get(["/list"],
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const info = await User.findById(user.userid).populate('curates', '_id date');
            const curates = info.curates;

            res.status(200).json(returnResponse(false, "careplus/list", curates));

            return;
        } catch (error) {
            console.error(error, "error at curating-pro.js - list GET");

            res.status(500).json(returnResponse(true, "error at /mapp/careplus/list", "-"));

            return;
        }
    }
);

router.get(["/post/:id"],
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const curate = await Curate.findById(req.params.id).populate(
                [
                    {path: 'posts'}, 
                    {path: 'ai_chats'},
                    {path: 'comments', populate: {path: 'doctor', select: 'name address phone email'}}
                ]
            );

            if (curate.user != user.userid) {
                res.status(800).json(returnResponse(true, "notYourCarePlusPost", "-"));
    
                return;
            }

            res.status(200).json(returnResponse(false, "careplus/post", curate));

            return;
        } catch (error) {
            console.error(error, "error at curating-pro.js - post GET");

            res.status(500).json(returnResponse(true, "error at /mapp/careplus/post", "-"));

            return;
        }
    }
);

module.exports = router;