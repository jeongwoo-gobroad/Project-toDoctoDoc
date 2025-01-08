require("dotenv").config();
const jwt = require('jsonwebtoken');
const UserSchema = require("../../models/User");
const secretKey = process.env.JWT_SECRET;
const mongoose = require("mongoose");
const Doctor = require("../../models/Doctor");
const Admin = require("../../models/Admin");
const User = mongoose.model("User", UserSchema);

const generateToken = (payload) => {
    const token = jwt.sign(payload, secretKey, {expiresIn: '1h'});

    return token;
};

const generateRefreshToken = () => {
    const refreshingToken = jwt.sign({}, secretKey, {expiresIn: '60d'});

    return refreshingToken;
};

const refreshingToken = (token) => {
    try {
        const decoded = jwt.verify(token, secretKey);

        const payload = {
            userid: decoded.userid,
            isPremium: decoded.isPremium,  
            isDoctor: decoded.isDoctor,
            isAdmin: decoded.isAdmin,
        };

        const newToken = generateToken(payload);

        return newToken;
    } catch (error) {
        // console.error("token error");

        return null;
    }
};

const getTokenInformation = async (req, res) => {
    try {
        const decoded = jwt.verify(req.headers["authorization"]?.split(" ")[1], secretKey);
        
        if (typeof decoded.userid === "undefined") {
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
                    isDoctor: user.isDoctor,
                    isAdmin: user.isAdmin,
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
                return null;
            }
            res.setHeader("Access_Token", token);
            res.setHeader("Refresh_Token", refreshToken);

            return payload; 

        } else {
            const payload = {
                userid: decoded.userid,
                isPremium: decoded.isPremium,
                isDoctor: decoded.isDoctor,
                isAdmin: decoded.isAdmin,
            };
    
            return payload;
        }
    } catch (error) {
        if (error.name === "TokenExpiredError") {
            return -1;
        }

        return null;
    }
};

module.exports = {generateToken, generateRefreshToken, refreshingToken, getTokenInformation};