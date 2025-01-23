const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../../models/User");
const returnResponse = require("../../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, generateRefreshToken } = require("../../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn } = require("../../checkingMiddleWare");
const returnLongLatOfAddress = require("../../../../middleware/getcoordinate");
const router = express.Router();

const User = mongoose.model("User", UserSchema);
const Doctor = require("../../../../models/Doctor");

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
            res.status(401).json(returnResponse(true, "errorAtDoctorPostDupemailcheck", "-"));

            return;
        }
    }
);

router.post(["/dupidcheck"],
    checkIfNotLoggedIn,
    async (req, res, next) => {
        const {id} = req.body;

        try {
            const doctor = await Doctor.findOne({id: id});

            if (doctor) {
                res.status(402).json(returnResponse(true, "doctor_id_already_exists", "-"));

                return;
            } else {
                res.status(200).json(returnResponse(false, "id_not_exists", "사용 가능한 이메일입니다."));

                return;
            }
        } catch (error) {
            res.status(401).json(returnResponse(true, "errorAtDoctorPostDupIdcheck", "-"));

            return;
        }
    }
);

router.post(["/login"], 
    checkIfNotLoggedIn, 
    async (req, res, next) => {
        const {userid, password, pushToken} = req.body;

        try {
            const doctor = await Doctor.findOne({id: userid});

            if (doctor && doctor.isVerified && await bcrypt.compare(password, doctor.password)) {
                const payload = {
                    userid: doctor._id,
                    isPremium: false,
                    isDoctor: true,
                    isAdmin: false,
                };

                const token = generateToken(payload);
                const refreshToken = generateRefreshToken();

                if (pushToken === null) {
                    await Doctor.findByIdAndUpdate(doctor._id, {
                        refreshToken: refreshToken,
                    });
                } else {
                    await Doctor.findByIdAndUpdate(doctor._id, {
                        refreshToken: refreshToken,
                        $push: {pushTokens: pushToken}
                    });
                }

                res.status(200).json(returnResponse(false, "logged_in", {token: token, refreshToken: refreshToken}));

                return;
            } else if (doctor && !doctor.isVerified) {
                res.status(601).json(returnResponse(true, "register_pending", "현재 인증 절차 진행 중입니다."));

                return;
            } else {
                res.status(403).json(returnResponse(true, "no_such_user", "등록된 유저가 없습니다."));

                return;
            }
        } catch (error) {
            console.error(error);

            res.status(401).json(returnResponse(true, "errorAtPostLogin", "-"));
        }
    }
);

router.get(["/logout"], 
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const {pushToken} = req.body;
            const user = await getTokenInformation(req, res);
    
            await Doctor.findByIdAndUpdate(user.userid, {
                $pull: {pushToken: pushToken}
            });
            console.log("pulled token");
    
            res.status(200).json(returnResponse(false, "loggedOut", "-"));
            
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
        const {
            id, password, password2, name, phone, personalID, doctorID, postcode, address, detailAddress, extraAddress, email
        } = req.body;

        const hashedPassword = await bcrypt.hash(password, 10);

        try {
            if (password != password2 || await Doctor.findOne({$or: [{id: id}, {personalID: personalID}, {doctorID: doctorID}]})) {
                res.status(400).json(returnResponse(true, "errorAtPostRegister", "회원가입 실패"));

                return;
            }

            const {long, lat} = await returnLongLatOfAddress(address);

            const doctor = await Doctor.create({
                id: id,
                password: hashedPassword,
                name: name,
                personalID: personalID,
                doctorID: doctorID,
                address: {
                    postcode: postcode,
                    address: address,
                    detailAddress: detailAddress,
                    extraAddress: extraAddress,
                    long: long,
                    lat: lat,
                },
                phone: phone,
                email: email,
                isVerified: false,
            });

            res.status(200).json(returnResponse(false, "register_pending", ""));

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "errorAtPostRegister", "회원가입 실패"));

            return;
        }
    }
);

module.exports = router;