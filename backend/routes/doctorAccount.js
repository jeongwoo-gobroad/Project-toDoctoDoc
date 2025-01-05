require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const mainLayout_Doctor = "../views/layouts/main_Doctor_LoggedIn";
const asyncHandler = require("express-async-handler");
const bcrypt = require("bcrypt");
const UserSchema = require("../models/User");
const AddressSchema = require("../models/Address");
const mongoose = require("mongoose");
const loginMiddleWare = require("./checkLogin");
const request = require("request");

const User = mongoose.models.User || mongoose.model("User", UserSchema);
const Address = mongoose.model("Address", AddressSchema);
const Doctor = require("../models/Doctor");
const returnLongLatOfAddress = require("../middleware/getcoordinate");
const { generateRefreshToken_web } = require("./web_auth/jwt_web");

router.get(["/"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res) => {
        const accountInfo = req.session.user;
        const pageInfo = {
            title: "Welcome to Mentally::의사 Home Menu"
        };

        res.render("doctor/doctor_home", {accountInfo, pageInfo, layout: mainLayout_Doctor});
    })
);

router.get(["/login"], 
    loginMiddleWare.ifNotLoggedInThenProceed, 
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::의사 Login"
        };

        res.render("user_auth/doctor_login", {pageInfo, layout: mainLayout});
}));

router.post(["/login"], 
    loginMiddleWare.ifNotLoggedInThenProceed, 
    asyncHandler(async (req, res) => {
        const {username, password} = req.body;

        try {
            const doctor = await Doctor.findOne({id: username});

            if (doctor && doctor.isVerified && await bcrypt.compare(password, doctor.password)) {
                req.session.user = doctor;
                req.session.isDoctor = true;

                res.cookie("token", generateToken_web({
                    userid: doctor._id,
                    isPremium: false,
                    isDoctor: true,
                    isAdmin: false
                }), {maxAge: 900000});
                const refresh = generateRefreshToken_web();
                res.cookie("refreshToken", refresh, {maxAge: 10800000});

                await Doctor.findByIdAndUpdate(doctor._id, {
                    refreshToken: refresh
                });

                res.redirect("/doctor");

                return;
            } else if (doctor && !doctor.isVerified) {
                res.redirect("/doctor/register/pending");

                return;
            } else {
                res.redirect("/doctor/login");

                return;
            }
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
}));

router.get(["/register"], 
    loginMiddleWare.ifNotLoggedInThenProceed, 
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::Doctor Register"
        };
    
        res.render("user_auth/doctor_register", {pageInfo, layout: mainLayout});
}));

router.post(["/register"], 
    loginMiddleWare.ifNotLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const {
            id, password, password2, name, phone, personalID, doctorID, postcode, address, detailAddress, extraAddress, email
        } = req.body;

        const hashedPassword = await bcrypt.hash(password, 10);

        if (password != password2 || await Doctor.findOne({$or: [{id: id}, {personalID: personalID}, {doctorID: doctorID}]})) {
            res.redirect("/error");

            return;
        }

        const kakaoMapOptions = {
            uri: encodeURI(`https://dapi.kakao.com/v2/local/search/address?query=${address}`),
            method: 'GET',
            json: true,
            headers: {
                Authorization: `KakaoAK ${process.env.KAKAO_REST_KEY}`
            }
        };
    
        try {
            request.get(kakaoMapOptions, async (err, result, body) => {
                const long = body.documents[0].address.x;
                const lat  = body.documents[0].address.y;
    
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
                        longitude: long,
                        latitude: lat,
                    },
                    phone: phone,
                    email: email,
                    isVerified: false,
                });
    
                res.redirect("/doctor/register/pending");
    
                return;
            });
        } catch (error) {
            console.log(error);
    
            res.redirect("/error");
    
            return;
        }
}));

router.get(["/register/pending"],
    loginMiddleWare.ifNotLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::Doctor Register Pending"
        };
    
        res.render("user_auth/doctor_register_pending", {pageInfo, layout: mainLayout});
    })
);

router.get(["/info"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const doctor = await Doctor.findById(req.session.user._id);

        const accountInfo = req.session.user;
        const pageInfo = {
            title: "Welcome to Mentally::의사 본인 정보 확인 및 수정 페이지"
        };

        res.render("doctor/doctor_edit", {
            accountInfo, pageInfo, doctor, layout: mainLayout_Doctor
        });
    })
);

router.patch(["/info"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const {
            password, password2, name, phone, postcode, address, detailAddress, extraAddress, email
        } = req.body;

        let newUserInfo;

        const {long, lat} = await returnLongLatOfAddress(address);

        newUserInfo = await Doctor.findByIdAndUpdate(req.session.user._id, {
            name: name,
            address: {
                postcode: postcode,
                address: address,
                detailAddress: detailAddress,
                extraAddress: extraAddress,
                longitude: long,
                latitude: lat
            },
            phone: phone,
            email: email
        }, {new: true});

        if (password.length > 1 && password == password2) {
            newUserInfo = await Doctor.findByIdAndUpdate(req.session.user._id,
                {
                    password: await bcrypt.hash(password, 10)
                },
                {new: true}
            );
        }

        req.session.user = newUserInfo;

        res.redirect("/doctor");

        return;
    })
);

module.exports = router;