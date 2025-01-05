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
const { getTokenInformation_web } = require("./web_auth/jwt_web");

const User = mongoose.models.User || mongoose.model("User", UserSchema);
const Address = mongoose.model("Address", AddressSchema);
const AccountLimitCount = mongoose.model("AccountLimitCount", AccountLimitCountSchema);

const ifPremiumThenProceed = asyncHandler (async (req, res, next) => {
    const u = await getTokenInformation_web(req, res);
    const user = await User.findById(u.userid);

    if (user.isPremium) {
        next();

        return;
    }

    res.redirect("/freeAccountError");

    return;
});

const ifDailyRequestNotExceededThenProceed = asyncHandler (async (req, res, next) => {
    const u = await getTokenInformation_web(req, res);
    const user = await User.findById(u.userid);

    if (user.isPremium) {
        next();

        return;
    }

    const limits = user.limits;
    const current = new Date();

    // console.log(limits.dailyRequestDate.toLocaleDateString());
    // console.log(current.toLocaleDateString());

    if (limits.dailyRequestDate.toLocaleDateString() !== current.toLocaleDateString()) {
        limits.dailyRequestDate = current;
        limits.dailyRequestCount = 0;
    }

    if (limits.dailyRequestCount >= 5) {
        res.redirect("/freeAccountError");

        return;
    } else {
        limits.dailyRequestCount += 1;

        try {
            await User.findByIdAndUpdate(req.session.user._id, {
                limits: limits
            });

            next();
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    }
});

const ifDailyChatNotExceededThenProceed = asyncHandler(async (req, res, next) => {
    const u = await getTokenInformation_web(req, res);
    const uid = u.userid;
    const user = await User.findById(uid);

    if (user.isPremium) {
        next();

        return;
    }

    const limits = user.limits;
    const current = new Date();

    if (limits.dailyChatDate.toDateString() !== current.toDateString()) {
        console.log("reset occured: " + limits.dailyChatDate.toDateString() + ", " + current.toDateString);
        limits.dailyChatDate = current;
        limits.dailyChatCount = 0;
    }

    if (limits.dailyChatCount >= 10) {
        res.send(JSON.stringify({chat: "일일 대화 한도 초과", isLimitExceeded: true}));

        return;
    } else {
        limits.dailyChatCount += 1;

        try {
            await User.findByIdAndUpdate(uid, {
                limits: limits
            });

            next();
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    }
});

module.exports = {ifDailyRequestNotExceededThenProceed, ifDailyChatNotExceededThenProceed, ifPremiumThenProceed};