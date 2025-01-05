require("dotenv").config();
const jwt = require('jsonwebtoken');
const UserSchema = require("../../models/User");
const secretKey = process.env.JWT_SECRET;
const mongoose = require("mongoose");
const User = mongoose.model("User", UserSchema);
const Doctor = require("../../models/Doctor");
const Admin = require("../../models/Admin");

const generateToken_web = (payload) => {
    const token = jwt.sign(payload, secretKey, {expiresIn: '15m'});

    return token;
};

const generateRefreshToken_web = () => {
    const refresh_Token = jwt.sign({}, secretKey, {expiresIn: '3h'});

    return refresh_Token;
};

const getTokenInformation_web = async (req, res) => {
    try {
        const decoded = jwt.verify(req.cookies.token, secretKey);
        
        const payload = {
            userid: decoded.userid,
            isPremium: decoded.isPremium,
            isDoctor: decoded.isDoctor,
            isAdmin: decoded.isAdmin,
        };

        return payload;
    } catch (error) {
        if (error.name === 'TokenExpiredError') { /* 토큰 만료시 리프레시 토큰을 활용해서 재인증하는 로직 */
            const user = await User.findOne({refreshToken: req.cookies.refreshToken});
            const doctor = await Doctor.findOne({refreshToken: req.cookies.refreshToken});
            const admin = await Admin.findOne({refreshToken: req.cookies.refreshToken});

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

                token = generateToken_web(payload);
                refreshToken = generateRefreshToken_web();

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

                token = generateToken_web(payload);
                refreshToken = generateRefreshToken_web();

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

                token = generateToken_web(payload);
                refreshToken = generateRefreshToken_web();

                await Admin.findByIdAndUpdate(admin._id, {
                    refreshToken: refreshToken,
                });
            } else {
                return null;
            }

            res.cookie("token", token, {httpOnly: true, maxAge: 900000});
            res.cookie("refreshToken", refreshToken, {httpOnly: true, maxAge: 10800000});
            // console.log("Token refreshed successfully");

            return payload; 
        }

        return null;
    }
};

module.exports = {generateToken_web, generateRefreshToken_web, getTokenInformation_web};