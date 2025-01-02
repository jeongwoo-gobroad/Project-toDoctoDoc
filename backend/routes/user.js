require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const asyncHandler = require("express-async-handler");
const bcrypt = require("bcrypt");
const UserSchema = require("../models/User");
const AddressSchema = require("../models/Address");
const AccountLimitCountSchema = require("../models/AccountLimitCount");
const mongoose = require("mongoose");
const loginMiddleWare = require("./checkLogin");
const request = require("request");
const returnLongLatOfAddress = require("../middleware/getcoordinate");

const User = mongoose.model("User", UserSchema);
const Address = mongoose.model("Address", AddressSchema);
const AccountLimitCount = mongoose.model("AccountLimitCount", AccountLimitCountSchema);

router.get(["/login"], asyncHandler(async (req, res) => {
    loginMiddleWare.ifLoggedInThenRedirectToMainPage(req, res);
    
    const pageInfo = {
        title: "Welcome to Mentally::Login"
    };

    res.render("user_auth/login", {pageInfo, layout: mainLayout});
}));

router.post(["/login"], asyncHandler(async (req, res) => {
    const {username, password} = req.body;

    try {
        const user = await User.findOne({id: username});

        if (user && await bcrypt.compare(password, user.password)) {
            req.session.user = user;

            res.redirect("/");

            return;
        } else {
            res.redirect("/login");

            return;
        }
    } catch (error) {
        res.redirect("/error");

        return;
    }  
}));

router.get(["/register"], asyncHandler(async (req, res) => {
    loginMiddleWare.ifLoggedInThenRedirectToMainPage(req, res);

    const pageInfo = {
        title: "Welcome to Mentally::Register"
    };

    res.render("user_auth/register", {pageInfo, layout: mainLayout});
}));

router.post(["/register"], asyncHandler(async (req, res) => {
    const {id, password, password2, nickname, postcode, address, detailAddress, extraAddress, email} = req.body;
    let addressData;
    let accountLimit;

    if (password != password2 || await User.findOne({id: id})) {
        // console.log("wow wtf?");

        res.redirect("/error");

        return; 
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const {long, lat} = await returnLongLatOfAddress(address);

    try {
        const loggedIn = await User.create({
            id: id,
            password: hashedPassword,
            usernick: nickname,
            address: {
                postcode: postcode,
                address: address,
                detailAddress: detailAddress,
                extraAddress: extraAddress,
                longitude: long,
                latitude: lat,
            },
            limits: {
                dailyRequestDate: Date.now(),
                dailyRequestCount: 0,
                dailyChatDate: Date.now(),
                dailyChatCount: 0
            },
            email: email,
        });

        req.session.user = loggedIn;

        res.redirect("/");

        return;
    } catch (error) {
        console.log(error);

        res.redirect("/error");

        return;
    }
}));

router.get(["/userInfo"], asyncHandler(async (req, res) => {
    loginMiddleWare.ifNotLoggedInThenRedirectToLoginPage(req, res);

    const pageInfo = {
        title: "Welcome to Mentally::User Information"
    };
    const accountInfo = {
        id: req.session.user.id,
        usernick: req.session.user.usernick,
        address: req.session.user.address,
        email: req.session.user.email,
    };

    res.render("user_auth/userInfo", {pageInfo, accountInfo, layout: mainLayout_LoggedIn});
}));

router.patch(["/userInfo"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const {nickname, password, password2, postcode, address, detailAddress, extraAddress, email} = req.body;

        try {
            let newUserInfo;

            const {long, lat} = await returnLongLatOfAddress(address);

            newUserInfo = await User.findByIdAndUpdate(req.session.user._id,
                {
                    usernick: nickname,
                    address: {
                        postcode: postcode,
                        address: address,
                        detailAddress: detailAddress,
                        extraAddress: extraAddress,
                        longitude: long,
                        latitude: lat,
                    },
                    email: email,
                },
                {new: true}
            ); 

            if (password.length > 1 && password == password2) {
                newUserInfo = await User.findByIdAndUpdate(req.session.user._id,
                    {
                        password: await bcrypt.hash(password, 10)
                    },
                    {new: true}
                );
            }

            req.session.user = newUserInfo;
    
            res.redirect("/");
    
            return;
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
}));

router.get(["/logout"], asyncHandler(async (req, res) => {
    req.session.destroy();

    res.redirect("/");
}));

module.exports = router;