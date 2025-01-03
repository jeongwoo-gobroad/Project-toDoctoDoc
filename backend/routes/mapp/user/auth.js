const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken } = require("../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn } = require("../checkingMiddleWare");
const { route } = require("../main");
const returnLongLatOfAddress = require("../../../middleware/getcoordinate");
const router = express.Router();

const User = mongoose.model("User", UserSchema);

router.post(["/login"], async (req, res, next) => {
    try {
        const {userid, password} = req.body;

        const user = await User.findOne({id: userid});

        // console.log(userid, password);

        if (!user) {
            res.status(401).json(returnResponse(true, "no_such_user", "등록된 유저가 없습니다."));
            return;
        }

        const isMatched = await bcrypt.compare(password, user.password);

        if (!isMatched) {
            res.status(401).json(returnResponse(true, "no_pass_match", "패스워드가 일치하지 않습니다."));
            return;
        }

        const payload = {
            userid: user._id,
            isPremium: user.isPremium,
            isDoctor: false,
            isAdmin: false,
        };

        const token = generateToken(payload);

        res.cookie('token', token, {httpOnly: true, maxAge: 10800000});
        res.status(200).json(returnResponse(false, "logged_in", token));
        
        return;
    } catch (error) {
        
        res.status(401).json(returnResponse(true, "errorAtPostLogin", "-"));
        return;
    }
});

router.get(["/logout"], 
    checkIfLoggedIn,
        (req, res, next) => {
            const token = req.headers["authorization"]?.split(" ")[1];

            const decoded = jwt.decode(token);

            if (!decoded) {
                res.status(401).json(returnResponse(true, "errorAtLogout", "로그아웃 실패"));
            }

            res.clearCookie('token');
            res.status(200).json(returnResponse(false, "successful_logout", "로그아웃 성공"));
        }
);

router.post(["/register"],
    checkIfNotLoggedIn,
    async (req, res, next) => {
        const {id, password, password2, nickname, postcode, address, detailAddress, extraAddress, email} = req.body;

        try {
            if (password != password2) {
                res.status(401).json(returnResponse(true, "password_not_match", "패스워드가 일치하지 않습니다."));
                return;
            }
            if (await User.findOne({id: id})) {
                res.status(401).json(returnResponse(true, "id_already_exists", "이미 존재하는 아이디입니다."));
                return;
            }

            const hashedPassword = await bcrypt.hash(password, 10);

            const {long, lat} = await returnLongLatOfAddress(address);

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
            });

            const payload = {
                userid: user._id,
                isPremium: user.isPremium,
                isDoctor: false,
                isAdmin: false,
            };
    
            const token = generateToken(payload);

            res.cookie('token', token, {httpOnly: true, maxAge: 10800000});
            res.status(200).json(returnResponse(false, "registered", "성공적으로 회원가입 되었습니다."));
        } catch (error) {
            res.status(401).json(returnResponse(true, "errorAtPostRegister", "회원가입 실패"));
            return;
        }
    }
);

module.exports = router;