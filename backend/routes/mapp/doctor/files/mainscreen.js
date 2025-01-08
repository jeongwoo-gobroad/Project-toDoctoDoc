require("dotenv").config();
const express = require("express");
const router = express.Router();
const openai = require("openai");
const { checkIfLoggedIn, ifTokenIsNotExpriredThenProceed, isDoctorThenProceed } = require("../../checkingMiddleWare");
const { ifDailyChatNotExceededThenProceed, ifDailyRequestNotExceededThenProceed } = require("../../limitMiddleWare");
const returnResponse = require("../../standardResponseJSON");
const { getTokenInformation } = require("../../../auth/jwt");
const UserSchema = require("../../../../models/User");
const { removeSpacesAndHashes } = require("../../../../serverSideWorks/tagCollection");
const Post = require("../../../../models/Post");
const mongoose = require("mongoose");
const returnLongLatOfAddress = require("../../../../middleware/getcoordinate");
const bcrypt = require("bcrypt");
const Doctor = require("../../../../models/Doctor");

const User = mongoose.model("User", UserSchema);

router.get(["/doctorInfo"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const doctor = await Doctor.findById(user.userid, '-password -chats -refreshToken');

            res.status(200).json(returnResponse(false, "doctorinfo", doctor));

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "doctorinfoerror", "doctorinfoerror"));

            return;
        }
    }
);

router.patch(["/editDoctorInfo"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const {
            password, password2, name, phone, postcode, address, detailAddress, extraAddress, email
        } = req.body;

        const user = await getTokenInformation(req, res);

        try {
            const {long, lat} = await returnLongLatOfAddress(address);

            await Doctor.findByIdAndUpdate(user.userid,
                {
                    name: name,
                    phone: phone,
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
            );

            if (password && password.length > 8 && password != password2) {
                res.status(401).json(returnResponse(true, "password_not_match", "password_not_match"));

                return;
            } else if (password && password.length > 8 && password == password2) {
                const hashedPassword = await bcrypt.hash(password, 10);

                await Doctor.findByIdAndUpdate(user.userid, {
                    password: hashedPassword
                });
            }

            res.status(200).json(returnResponse(false, "editinfo", "-"));

            return;
        } catch (error) {
            console.error(error);

            res.status(401).json(returnResponse(true, "editdoctorinfoerror", "editdoctorinfoerror"));

            return;
        }
    }
);

module.exports = router;