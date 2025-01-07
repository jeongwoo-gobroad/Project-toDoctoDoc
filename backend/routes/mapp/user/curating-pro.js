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
const { ifLoggedInThenProceed } = require("../../checkLogin");

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

router.delete(["/post/:id"],
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        try {
            const user = await getTokenInformation(req, res);
            const curate = await Curate.findById(req.params.id);

            if (!user) {
                res.status(401).json(returnResponse(true, "no such user", "-"));

                return;
            }
            if (!curate) {
                res.status(402).json(returnResponse(true, "no such curate", "-"));

                return;
            }
            if (curate.user != user.userid) {
                res.status(403).json(returnResponse(true, "not your curate", "-"));

                return;
            }

            await User.findByIdAndUpdate(user.userid, {
                $pull: {curates: curate._id} 
            });
            await Curate.findByIdAndDelete(curate._id);

            res.status(200).json(returnResponse(false, "curate deletion succeeded", {}));

            return;
        } catch (error) {
            res.status(400).json(returnResponse(true, "curating deletion failed", "-"));

            return;
        }
    }
);

router.post(["/curate"], 
    checkIfLoggedIn,
    ifPremiumThenProceed,
    async (req, res, next) => {
        try {
            const user = await getTokenInformation(req, res);

            const curate = new Curate;

            const data = await User.findById(user.userid).populate('posts ai_chats');
            curate.user = user.userid;

            data.posts.sort((a, b) => {
                return b.editedAt - a.editedAt;
            });
            data.ai_chats.sort((a, b) => {
                return b.chatEditedAt - a.chatEditedAt;
            });

            if (data.posts.length >= 5) {
                curate.posts = data.posts.slice(0, 5);
            } else {
                curate.posts = data.posts;
            }
            if (data.ai_chats.length >= 5) {
                curate.ai_chats = data.ai_chats.slice(0, 5);
            } else {    
                curate.ai_chats = data.ai_chats;
            }

            await curate.save();
            await User.findByIdAndUpdate(user.userid, {
                $push: {curates: curate._id}
            });

            // console.log(curate);

            res.status(200).json(returnResponse(false, "curating succeeded", {_id: curate._id}));

            return;
        } catch (error) {
            res.status(400).json(returnResponse(true, "curating failed", "-"));

            return;
        }
    } 
);

module.exports = router;