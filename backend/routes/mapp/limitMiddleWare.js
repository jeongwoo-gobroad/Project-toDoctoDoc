const mongoose = require("mongoose");
const { getTokenInformation } = require("../auth/jwt");
const UserSchema = require("../../models/User");
const returnResponse = require("./standardResponseJSON");
const User = mongoose.model('User', UserSchema);

const ifDailyRequestNotExceededThenProceed = async (req, res, next) => {
    const user = getTokenInformation(req.cookies.token);

    if (user.isPremium) {
        next();

        return;
    }

    const db = await User.findById(user.userid);

    const limits = db.limits;
    const current = new Date();

    if (limits.dailyRequestDate.toLocaleDateString() !== current.toLocaleDateString()) {
        limits.dailyRequestDate = current;
        limits.dailyRequestCount = 0;
    }

    if (limits.dailyRequestCount >= 5) {
        res.status(401).json(returnResponse(true, "moreThan5", "지정된 호출 횟수 초과"));

        return;
    } else {
        limits.dailyRequestCount += 1;

        try {
            await User.findByIdAndUpdate(user.userid, {
                limits: limits
            });

            next();

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "mongodberror", "몽고DB 에러"));

            return;
        }
    }
};

const ifDailyChatNotExceededThenProceed = async (req, res, next) => {
    const user = getTokenInformation(req.cookies.token);

    if (user.isPremium) {
        next();

        return;
    }

    const db = await User.findById(user.userid);

    const limits = db.limits;
    const current = new Date();

    if (limits.dailyChatDate.toDateString() !== current.toDateString()) {
        limits.dailyChatDate = current;
        limits.dailyChatCount = 0;
    }

    if (limits.dailyChatCount >= 10) {
        res.status(401).json(returnResponse(true, "moreThan10", "지정된 호출 횟수 초과"));

        return;
    } else {
        limits.dailyChatCount += 1;

        try {
            await User.findByIdAndUpdate(user.userid, {
                limits: limits
            });

            next();

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "mongodberror", "몽고DB 에러"));

            return;
        }
    }
};

module.exports = {ifDailyRequestNotExceededThenProceed, ifDailyChatNotExceededThenProceed};