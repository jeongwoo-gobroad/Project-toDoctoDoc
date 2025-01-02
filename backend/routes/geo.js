require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const asyncHandler = require("express-async-handler");
const bcrypt = require("bcrypt");
const UserSchema = require("../models/User");
const Post = require("../models/Post");
const mongoose = require("mongoose");
const loginMiddleWare = require("./checkLogin");

const User = mongoose.model("User", UserSchema);

router.get(["/"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::Geo",
            apikey: process.env.KAKAO_KEY,
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("geolocation/geoshow", {pageInfo, accountInfo, layout:mainLayout_LoggedIn});
    })
);

router.post(["/apiAccess"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        
    })
);

module.exports = router;