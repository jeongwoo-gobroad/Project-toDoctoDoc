require("dotenv").config();
const jwt = require('jsonwebtoken');
const UserSchema = require("../../models/User");
const secretKey = process.env.JWT_SECRET;
const mongoose = require("mongoose");
const Doctor = require("../../models/Doctor");
const Admin = require("../../models/Admin");
const returnResponse = require("../mapp/standardResponseJSON");
const { generateToken, generateRefreshToken } = require("./jwt");
const User = mongoose.model("User", UserSchema);
const router = require('express').Router();

router.post(["/tokenRefresh"], 
    async (req, res, next) => {
        // console.log("Refresh request");

        try {
            const decoded = jwt.verify(req.headers["authorization"]?.split(" ")[1], secretKey);
            
            if (typeof decoded.userid === "undefined") {

                // console.log(req.headers["authorization"]?.split(" ")[1]);

                const user = await User.findOne({refreshToken: req.headers["authorization"]?.split(" ")[1]});
                const doctor = await Doctor.findOne({refreshToken: req.headers["authorization"]?.split(" ")[1]});
                const admin = await Admin.findOne({refreshToken: req.headers["authorization"]?.split(" ")[1]});
    
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
    
                    await User.findByIdAndUpdate(user._id, {
                        refreshToken: refreshToken,
                    });
                } else if (doctor) {
                    payload = {
                        userid: doctor._id,
                        isPremium: false,
                        isDoctor: true,
                        isAdmin: false,
                    };
    
                    token = generateToken(payload);
                    refreshToken = generateRefreshToken();
    
                    await Doctor.findByIdAndUpdate(doctor._id, {
                        refreshToken: refreshToken,
                    });
                } else if (admin) {
                    payload = {
                        userid: admin._id,
                        isPremium: false,
                        isDoctor: false,
                        isAdmin: true,
                    };
    
                    token = generateToken(payload);
                    refreshToken = generateRefreshToken();
    
                    await Admin.findByIdAndUpdate(admin._id, {
                        refreshToken: refreshToken,
                    });
                } else {
                    res.status(403).json(returnResponse(true, "unexpectedError", "-"));

                    console.error("errorAtTokenRefreshing");

                    return;
                }
                // console.log("Token refreshed successfully");

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