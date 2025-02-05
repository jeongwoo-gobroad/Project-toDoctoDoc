require("dotenv").config();
const express = require("express");
const router = express.Router();
const openai = require("openai");
const { checkIfLoggedIn, ifTokenIsNotExpriredThenProceed } = require("../checkingMiddleWare");
const { ifDailyChatNotExceededThenProceed } = require("../limitMiddleWare");
const returnResponse = require("../standardResponseJSON");
const { getTokenInformation } = require("../../auth/jwt");
const UserSchema = require("../../../models/User");
const { tagMap, tagGraph } = require("../../../serverSideWorks/tagCollection");
const Post = require("../../../models/Post");
const mongoose = require("mongoose");
const { tagCountBubbleMap } = require("../../../serverSideWorks/bubbleCollection");
const { getHashAll } = require("../../../middleware/redisCaching");

const User = mongoose.model("User", UserSchema);

router.get(["/tagSearch/:tag"],
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const data = await Post.find({tag: new RegExp(req.params.tag.split(",").join('|'), 'i')}).sort({editedAt: "desc"});

            res.status(200).json(returnResponse(false, "tagSearchResult", data));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtTagSearch", "-"));

            return;
        }
    }
);

router.get(["/graphBoard"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const usr = await User.findById(user.userid);
            const temp = await getHashAll("GRAPHBOARD:");

            for (const tag of usr.bannedTags) {
                if (temp.has(tag)) {
                    temp.delete(tag);
                }
            }

            const _bubbleList = JSON.stringify(temp);

            console.log(_bubbleList);

            res.status(200).json(returnResponse(false, "graphBoardData", {_bubbleList: _bubbleList}));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(false, "errorAtGraphBoard", "-"));

            console.error(error, "errorAtGraphBoard");

            return;
        }
    }
);

router.post(["/tagBan"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const {tag} = req.body;
        const user = await getTokenInformation(req, res);

        try {  
            await User.findByIdAndUpdate(user.userid, {
                $push: {bannedTags: tag}
            });

            res.status(200).json(returnResponse(false, "tagBanned", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtTagBan", "-"));

            console.error(error, "errorAtTagBan");

            return;
        }
    }
);

router.get(["/bannedTags"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const usr = await User.findById(user.userid);

            res.status(200).json(returnResponse(false, "bannedTags", {list: usr.bannedTags}));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtBannedTags", "-"));

            console.error(error, "errorAtBannedTags");

            return;
        }
    }
);

router.delete(["/tagUnBan"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const {tag} = req.body;
        const user = await getTokenInformation(req, res);

        try {  
            await User.findByIdAndUpdate(user.userid, {
                $pull: {bannedTags: tag}
            });

            res.status(200).json(returnResponse(false, "tagUnBanned", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtTagUnBan", "-"));

            console.error(error, "errorAtTagUnBan");

            return;
        }
    }
);

module.exports = router;