require("dotenv").config();
const jwt = require('jsonwebtoken');
const { isDoctor, isAdmin } = require("../checkLogin");
const secretKey = process.env.JWT_SECRET;

const generateToken = (payload) => {
    const token = jwt.sign(payload, secretKey, {expiresIn: '3h'});

    return token;
};

const refreshToken = (token) => {
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
        console.error("token error");

        return null;
    }
};

const getTokenInformation = (req) => {
    try {
        const decoded = jwt.verify(req.headers["authorization"]?.split(" ")[1], secretKey);

        const payload = {
            userid: decoded.userid,
            isPremium: decoded.isPremium,
            isDoctor: decoded.isDoctor,
            isAdmin: decoded.isAdmin,
        };

        return payload;
    } catch (error) {
        console.error("token error");

        return null;
    }
};

module.exports = {generateToken, refreshToken, getTokenInformation};