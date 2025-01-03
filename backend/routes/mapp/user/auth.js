const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken } = require("../../auth/jwt");
const { checkIfLoggedIn } = require("../checkingMiddleWare");
const router = express.Router();

const User = mongoose.model("User", UserSchema);

router.post(["/login"], async (req, res, next) => {
    try {
        const {userid, password} = req.body;

        const user = await User.findOne({id: userid});

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
        res.status(200).json(returnResponse(false, "logged_in", "성공적으로 로그인 되었습니다."));
        return;
    } catch (error) {
        res.status(401).json(returnResponse(true, "errorAtPostLogin", "-"));
        return;
    }
});

router.get(["/logout"], 
    checkIfLoggedIn,
        (req, res, next) => {
            const token = req.cookies.token;

            const decoded = jwt.decode(token);

            if (!decoded) {
                res.status(401).json(returnResponse(true, "errorAtLogout", "로그아웃 실패"));
            }

            res.clearCookie('token');
            res.status(200).json(returnResponse(false, "successful_logout", "로그아웃 성공"));
        }
);

module.exports = router;