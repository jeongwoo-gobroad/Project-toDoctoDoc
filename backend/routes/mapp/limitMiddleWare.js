const mongoose = require("mongoose");
const UserSchema = require("../../models/User");
const returnResponse = require("./standardResponseJSON");
const User = mongoose.model('User', UserSchema);

const ifDailyRequestNotExceededThenProceed = async (req, res, next) => {
    try {
        const db = await User.findById(req.userid);
    
        const limits = db.limits;
        const current = new Date();
    
        if (limits.dailyRequestDate.toLocaleDateString() !== current.toLocaleDateString()) {
            limits.dailyRequestDate = current;
            limits.dailyRequestCount = 0;
        }
    
        if (limits.dailyRequestCount >= 10) {
            res.status(555).json(returnResponse(true, "moreThan10", "지정된 호출 횟수 초과"));
    
            return;
        } else {
            limits.dailyRequestCount += 1;
    
            try {
                await User.findByIdAndUpdate(req.userid, {
                    limits: limits
                });
    
                next();
    
                return;
            } catch (error) {
                res.status(401).json(returnResponse(true, "mongodberror", "몽고DB 에러"));
    
                return;
            }
        }
    } catch (error) {
        console.log(error, "errorAtIfDailyRequestNotExceededThenProceed");

        res.status(401).json(returnResponse(true, "errorAtIfDailyRequestNotExceededThenProceed", "-"));
    
        return;
    }
};

const ifDailyRequestNotExceededThenProceed_chatHintMessage = async (req, res, next) => {
    try {
        const db = await User.findById(req.userid);
    
        const limits = db.limits;
        const current = new Date();
    
        if (limits.dailyRequestDate.toLocaleDateString() !== current.toLocaleDateString()) {
            limits.dailyRequestDate = current;
            limits.dailyRequestCount = 0;
        }
    
        if (limits.dailyRequestCount >= 10) {
            res.status(555).json(returnResponse(true, "moreThan10", "지정된 호출 횟수 초과"));
    
            return;
        } else {
            try {
                next();
    
                return;
            } catch (error) {
                res.status(500).json(returnResponse(true, "mongodberror", "몽고DB 에러"));
    
                return;
            }
        }
    } catch (error) {
        console.log(error, "errorAtIfDailyRequestNotExceededThenProceed");

        res.status(500).json(returnResponse(true, "errorAtIfDailyRequestNotExceededThenProceed", "-"));
    
        return;
    }
};

const ifDailyChatNotExceededThenProceed = async (req, res, next) => {

    // if (user.isPremium) {
    //     next();

    //     return;
    // }

    try {
        const db = await User.findById(req.userid);
    
        const limits = db.limits;
        const current = new Date();
    
        if (limits.dailyChatDate.toDateString() !== current.toDateString()) {
            limits.dailyChatDate = current;
            limits.dailyChatCount = 0;
        }
    
        if (limits.dailyChatCount >= 50) {
            res.status(555).json(returnResponse(true, "moreThan50", "지정된 호출 횟수 초과"));
    
            return;
        } else {
            // limits.dailyChatCount += 1;
    
            try {
                next();
    
                return;
            } catch (error) {
                res.status(401).json(returnResponse(true, "mongodberror", "몽고DB 에러"));
    
                return;
            }
        }
    } catch (error) {
        console.error(error, "errorAtIfDailyChatNotExceededThenProceed");

        res.status(401).json(returnResponse(true, "errorAtIfDailyChatNotExceededThenProceed", "-"));

        return;
    }
};

const ifDailyCurateNotExceededThenProceed = async (req, res, next) => {
    try {
        const db = await User.findById(req.userid);
    
        const limits = new Date(db.recentCurateDate);
        const current = new Date();
    
        if (limits.toDateString() !== current.toDateString()) {
            db.recentCurateDate = current;
            await db.save();
            next();
        } else {
            res.status(450).json(returnResponse(true, "cannotPublishCurateMoreThanOnceInADay", "지정된 등록 횟수 초과"));
    
            return;
        }
    } catch (error) {
        console.error(error, "errorAtIfDailyCurateNotExceededThenProceed");

        res.status(401).json(returnResponse(true, "errorAtIfDailyCurateNotExceededThenProceed", "-"));

        return;
    }
};

module.exports = {
    ifDailyRequestNotExceededThenProceed, 
    ifDailyChatNotExceededThenProceed, 
    ifDailyCurateNotExceededThenProceed,
    ifDailyRequestNotExceededThenProceed_chatHintMessage,
};