require("dotenv").config();
const express = require("express");
const router = express.Router();
const openai = require("openai");
const { checkIfLoggedIn, ifTokenIsNotExpriredThenProceed } = require("../checkingMiddleWare");
const { ifDailyChatNotExceededThenProceed } = require("../limitMiddleWare");
const returnResponse = require("../standardResponseJSON");
const { getTokenInformation } = require("../../auth/jwt");
const UserSchema = require("../../../models/User");
const { removeSpacesAndHashes } = require("../../../serverSideWorks/tagCollection");
const Post = require("../../../models/Post");
const mongoose = require("mongoose");

const User = mongoose.model("User", UserSchema);

router.get(["/tagSearch/:tag"],
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const data = await Post.find({tag: new RegExp(req.params.tag, 'i')}).sort({editedAt: "desc"});

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
        const tagList = JSON.stringify(Object.fromEntries(serverWorks.tagMap));
        const tagGraph = JSON.stringify(serverWorks.tagGraph);

        res.status(200).json(returnResponse(false, "graphBoardData", {tagList, tagGraph}));

        return;
    }
);

module.exports = router;