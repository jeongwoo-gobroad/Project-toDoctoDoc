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
const { bubbleMap } = require("../../../serverSideWorks/bubbleCollection");

const User = mongoose.model("User", UserSchema);

router.get(["/tagSearch/:tag"],
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const data = await Post.find({tag: new RegExp(req.params.tag.split(",").join('|'), 'i')}).sort({editedAt: "desc"});

            res.status(200).json(returnResponse(false, "tagSearchResult", data));
        } catch (error) {
            res.status(401).json(returnResponse(true, "errorAtTagSearch", "-"));

            return;
        }
    }
);

router.get(["/graphBoard"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const _bubbleList = JSON.stringify(Object.fromEntries(bubbleMap));
        const _tagList = JSON.stringify(Object.fromEntries(tagMap));
        const _tagGraph = JSON.stringify(tagGraph);

        res.status(200).json(returnResponse(false, "graphBoardData", {_tagList: _tagList, _tagGraph: _tagGraph}));

        return;
    }
);

module.exports = router;