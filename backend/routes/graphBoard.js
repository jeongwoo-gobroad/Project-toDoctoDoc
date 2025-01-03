require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const Post = require("../models/Post");
const asyncHandler = require("express-async-handler");
const bcrypt = require("bcrypt");
const loginMiddleWare = require("./checkLogin");
const serverWorks = require("../serverSideWorks/tagCollection");

router.get(["/tagSearch/:tag"], 
    loginMiddleWare.ifLoggedInThenProceed, 
    asyncHandler( async (req, res) => {
        let data;

        try {
            // console.log(new RegExp(req.params.tag, 'i'));
            data = await Post.find({tag: new RegExp(req.params.tag, 'i')}).sort({editedAt: "desc"});
        } catch (error) {
            res.redirect("/error");

            return;
        }

        const pageInfo = {
            title: "Welcome to Mentally::Tag Search Result"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("graphBoard/graphBoard_posts", {pageInfo, accountInfo, data, layout: mainLayout_LoggedIn});
}));

router.get(["/graphBoard"], 
    loginMiddleWare.ifLoggedInThenProceed, 
    asyncHandler (async (req, res) => {
        const tagList = JSON.stringify(Object.fromEntries(serverWorks.tagMap));
        const tagGraph = JSON.stringify(serverWorks.tagGraph);

        const pageInfo = {
            title: "Welcome to Mentally::Tag Search Result"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("graphBoard/graphBoard_home", {pageInfo, accountInfo, tagList, tagGraph, layout: mainLayout_LoggedIn});
}));

module.exports = router;