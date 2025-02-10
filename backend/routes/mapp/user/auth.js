const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, generateRefreshToken, getTokenInformation } = require("../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn } = require("../checkingMiddleWare");
const returnLongLatOfAddress = require("../../../middleware/getcoordinate");
const router = express.Router();
const Doctor = require("../../../models/Doctor");
const Redis = require("../../../config/redisObject");
const User = mongoose.model("User", UserSchema);

router.post(["/dupidcheck"], 
    checkIfNotLoggedIn,
    async (req, res, next) => {
        const {userid} = req.body;

        try {
            const user = await User.findOne({id: userid});

            if (user) {
                res.status(402).json(returnResponse(true, "id_already_exists", "이미 존재하는 아이디입니다."));
                return;
            } else {    
                res.status(200).json(returnResponse(false, "id_not_exists", "사용 가능한 아이디입니다."));
                return;
            }
        } catch (error) {
            res.status(401).json(returnResponse(true, "errorAtPostDupidcheck", "-"));
            return;
        }
    }
);

router.post(["/dupemailcheck"],
    checkIfNotLoggedIn,
    async (req, res, next) => {
        const {email} = req.body;

        try {
            const user = await User.findOne({email: email});
            const doctor = await Doctor.findOne({email: email});

            if (user || doctor) {
                res.status(402).json(returnResponse(true, "email_already_exists", "이미 존재하는 이메일입니다."));
                return;
            } else {    
                res.status(200).json(returnResponse(false, "email_not_exists", "사용 가능한 이메일입니다."));
                return;
            }
        } catch (error) {
            res.status(401).json(returnResponse(true, "errorAtPostDupemailcheck", "-"));
            return;
        }
    }
);

router.post(["/login"], async (req, res, next) => {
    try {
        const {userid, password, deviceId, pushToken} = req.body;
        let redis = new Redis();
        const user = await User.findOne({id: userid});

        // console.log(userid, password);

        if (!user) {
            res.status(401).json(returnResponse(true, "no_such_user", "등록된 유저가 없습니다."));
            return;
        }

        const isMatched = await bcrypt.compare(password, user.password);

        if (!isMatched) {
            res.status(402).json(returnResponse(true, "no_pass_match", "패스워드가 일치하지 않습니다."));
            return;
        }

        const payload = {
            userid: user._id,
            isPremium: user.isPremium,
            isDoctor: false,
            isAdmin: false,
        };

        const token = generateToken(payload);
        const refreshToken = generateRefreshToken();

        if (!deviceId) { // Desktop version
            await User.findByIdAndUpdate(user._id, {
                refreshToken: refreshToken,
            });
            await redis.setCacheForNDaysAsync("DEVICE:" + user._id, pushToken, 270);
        } else {
            if (user.deviceIds.includes(deviceId)) {
                // console.log("sameDevice");
                const prevToken = await redis.getCache("DEVICE:" + deviceId);
                await User.findByIdAndUpdate(user._id, {
                    refreshToken: refreshToken,
                });
                if (prevToken != pushToken) { // 만약 토큰이 갱신되었다면
                    await redis.setCacheForNDaysAsync("DEVICE:" + deviceId, pushToken, 270);
                }
            } else {
                // console.log(deviceId, "->", pushToken); // 하지메떼노 등록
                await User.findByIdAndUpdate(user._id, {
                    refreshToken: refreshToken,
                    $push: {deviceIds: deviceId}
                });
                await redis.setCacheForNDaysAsync("DEVICE:" + deviceId, pushToken, 270);
            }
        }

        redis.closeConnnection();
        redis = null;

        res.status(200).json(returnResponse(false, "logged_in", {token: token, refreshToken: refreshToken}));
        
        return;
    } catch (error) {
        console.error(error, "errorAtPostLogin_user");
        
        res.status(403).json(returnResponse(true, "errorAtPostLogin", "-"));
        return;
    }
});

router.get(["/logout"], 
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const {deviceId} = req.body;
            const user = await getTokenInformation(req, res);
            let redis = new Redis();
    
            await User.findByIdAndUpdate(user.userid, {
                $pull: {deviceIds: deviceId}
            });
            redis.delCache("Device: " + deviceId);
            console.log("pulled device ID");
    
            res.status(200).json(returnResponse(false, "loggedOut", "-"));

            redis.closeConnnection();
            redis = null;
            
            return;
        } catch (error) {
            
            res.status(403).json(returnResponse(true, "errorAtGetLogout", "-"));
            return;
        }
    }
);

router.post(["/register"],
    checkIfNotLoggedIn,
    async (req, res, next) => {
        const {id, password, password2, nickname, postcode, address, detailAddress, extraAddress, email} = req.body;

        // console.log(req.body);

        try {
            if (password != password2) {
                res.status(402).json(returnResponse(true, "password_not_match", "패스워드가 일치하지 않습니다."));
                return;
            }
            if (await User.findOne({id: id})) {
                res.status(403).json(returnResponse(true, "id_already_exists", "이미 존재하는 아이디입니다."));
                return;
            }

            const hashedPassword = await bcrypt.hash(password, 10);

            const {long, lat} = await returnLongLatOfAddress(address);

            const refreshToken = generateRefreshToken();

            const user = await User.create({
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
                refreshToken: refreshToken
            });

            const payload = {
                userid: user._id,
                isPremium: user.isPremium,
                isDoctor: false,
                isAdmin: false,
            };
    
            const token = generateToken(payload);

            res.status(200).json(returnResponse(false, "registered", {token: token, refreshToken: refreshToken}));
        } catch (error) {
            console.error(error, "errorAtPostRegister");

            res.status(401).json(returnResponse(true, "errorAtPostRegister", "회원가입 실패"));
            return;
        }
    }
);

module.exports = router;