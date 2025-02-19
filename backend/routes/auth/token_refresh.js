require("dotenv").config();
const jwt = require('jsonwebtoken');
const UserSchema = require("../../models/User");
const secretKey = process.env.JWT_SECRET;
const mongoose = require("mongoose");
const Doctor = require("../../models/Doctor");
const Admin = require("../../models/Admin");
const returnResponse = require("../mapp/standardResponseJSON");
const { generateToken, generateRefreshToken } = require("./jwt");
const Redis = require("../../config/redisObject");
const User = mongoose.model("User", UserSchema);
const router = require('express').Router();

router.post(["/tokenRefresh"], 
    async (req, res, next) => {
        // console.log("Refresh request");

        try {
            const originalRefreshToken = req.headers["authorization"]?.split(" ")[1];
            const decoded = jwt.verify(originalRefreshToken, secretKey);
            
            if (typeof decoded.userid === "undefined") {

                let redis = new Redis();
                let user = null;
                let doctor = null;
                let admin = null;

                await redis.connect();

                const object = await redis.getHashValue("TOKEN:", originalRefreshToken);

                if (object) {
                    if (object.userStatus === "user") {
                        user = await User.findById(object.userId);
                    } else if (object.userStatus === "doctor") {
                        doctor = await Doctor.findById(object.userId);
                    } else if (object.userStatus === "admin") {
                        admin = await Admin.findById(object.userId);
                    }
                }

                await redis.delHashValue("TOKEN:", originalRefreshToken);
    
                let payload = null;
                let token = null;
                let refreshToken = null;
    
                if (user) {
                    payload = {
                        userid: user._id,
                        isPremium: user.isPremium,
                        isDoctor: false,
                        isAdmin: false,
                    };
    
                    token = generateToken(payload);
                    refreshToken = generateRefreshToken();
    
                    // await User.findByIdAndUpdate(user._id, {
                    //     refreshToken: refreshToken,
                    // });

                    await redis.setHashValueWithTTL("TOKEN:", refreshToken, {userStatus: "user", userId: user._id}, 60);
                } else if (doctor) {
                    payload = {
                        userid: doctor._id,
                        isPremium: false,
                        isDoctor: true,
                        isAdmin: false,
                    };
    
                    token = generateToken(payload);
                    refreshToken = generateRefreshToken();
    
                    // await Doctor.findByIdAndUpdate(doctor._id, {
                    //     refreshToken: refreshToken,
                    // });

                    await redis.setHashValueWithTTL("TOKEN:", refreshToken, {userStatus: "doctor", userId: doctor._id}, 60);
                } else if (admin) {
                    payload = {
                        userid: admin._id,
                        isPremium: false,
                        isDoctor: false,
                        isAdmin: true,
                    };
    
                    token = generateToken(payload);
                    refreshToken = generateRefreshToken();
    
                    // await Admin.findByIdAndUpdate(admin._id, {
                    //     refreshToken: refreshToken,
                    // });

                    await redis.setHashValueWithTTL("TOKEN:", refreshToken, {userStatus: "admin", userId: admin._id}, 60);
                } else {
                    redis.closeConnnection();
                    redis = null;

                    res.status(403).json(returnResponse(true, "unexpectedError", "-"));

                    console.error("errorAtTokenRefreshing");

                    return;
                }
                // console.log("Token refreshed successfully");
                redis.closeConnnection();
                redis = null;

                res.status(200).json(returnResponse(false, "returnedTokenSuccessfully", {accessToken: token, refreshToken: refreshToken}));
    
    
            } else {
                res.status(401).json(returnResponse(true, "unauthorizedToken", "-"));

                return;
            }
        } catch (error) {
            console.log(error, "errorAtTokenRefreshing");

            if (error.name === "TokenExpiredError") {
                res.status(419).json(returnResponse(true, "tokenExpired", "-"));

                return;
            }
    
            res.status(403).json(returnResponse(true, "unexpectedError", "-"));

            return;
        }
    }
);

module.exports = router;