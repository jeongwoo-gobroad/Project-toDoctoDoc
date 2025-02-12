const express = require("express");
const mongoose = require("mongoose");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const { getTokenInformation } = require("../../auth/jwt");
const { checkIfLoggedIn } = require("../checkingMiddleWare");
const router = express.Router();

const User = mongoose.model("User", UserSchema);
const { ifDailyCurateNotExceededThenProceed } = require("../limitMiddleWare");
const Curate = require("../../../models/Curate");
const Comment = require("../../../models/Comment");
const openai = require("openai");

router.get(["/list"],
    checkIfLoggedIn,
    // ifPremiumThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const info = await User.findById(user.userid).populate('curates', '_id date comments isNotRead');
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
    // ifPremiumThenProceed,
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

            if (curate.isNotRead) {
                curate.isNotRead = false;
                await curate.save();
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
    // ifPremiumThenProceed,
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
                $pull: {curates: curate._id},
                recentCurateDate: "", 
            });
            for (const comment of curate.comments) {
                await Comment.findByIdAndDelete(comment);
            }
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
    // ifPremiumThenProceed,
    ifDailyCurateNotExceededThenProceed,
    async (req, res, next) => {
        try {
            const curate = new Curate;

            const data = await User.findById(req.userid).populate('posts ai_chats');
            curate.user = req.userid;

            data.posts.sort((a, b) => {
                // console.log("This happens first");
                return b.editedAt - a.editedAt;
            });
            data.ai_chats.sort((a, b) => {
                // console.log("This happens second");
                return b.chatEditedAt - a.chatEditedAt;
            });

            // console.log("This happens third");
            if (data.posts.length >= 40) {
                curate.posts = data.posts.slice(0, 40);
            } else {
                curate.posts = data.posts;
            }
            // console.log("This happens fourth");
            if (data.ai_chats.length >= 20) {
                curate.ai_chats = data.ai_chats.slice(0, 20);
            } else {    
                curate.ai_chats = data.ai_chats;
            }

            let messages = [];
            messages.push({
                "role": "developer",
                "content": "너는 전문 심리 상담사고, 내가 제시한, 환자가 품고 있는 걱정 및 대화 내용을 기반으로 이 환자가 어떠한 것 때문에 마음이 아픈지 주치의에게 설명해줘"
            });
            for (const post of curate.posts) {
                messages.push({
                    "role": "user",
                    "content": post.title
                });
            }
            for (const ai_chat of curate.ai_chats) {
                messages.concat(ai_chat.response);
            }

            const target = new openai({
                apiKey: process.env.OPENAI_KEY
            });

            const completion = await target.chat.completions.create({
                "model": "gpt-4o",
                "store": false,
                "messages": messages
            });

            const message = completion.choices[0].message.content;

            curate.deepCurate = message;

            await curate.save();
            await User.findByIdAndUpdate(req.userid, {
                $push: {curates: curate._id},
                recentCurateDate: Date.now(),
                recentCurate: curate._id,
            });

            // console.log(curate);

            res.status(200).json(returnResponse(false, "curating succeeded", {_id: curate._id}));

            return;
        } catch (error) {
            console.error(error, "errorAtCurating");

            res.status(400).json(returnResponse(true, "curating failed", "-"));

            return;
        }
    } 
);

module.exports = router;