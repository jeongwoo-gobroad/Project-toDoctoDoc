require("dotenv").config();
const jwt = require('jsonwebtoken');
const UserSchema = require("../../models/User");
const secretKey = process.env.JWT_SECRET;
const mongoose = require("mongoose");
const User = mongoose.model("User", UserSchema);

const generateToken = (payload) => {
    const token = jwt.sign(payload, secretKey, {expiresIn: '1h'});

    return token;
};

const generateRefreshToken = () => {
    const refreshToken = jwt.sign({}, secretKey, {expiresIn: '60d'});

    return refreshToken;
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
<<<<<<< HEAD
        console.error("token error5");
=======
        // console.error("token error5");
>>>>>>> 75ad042e5ba3ed4c774e0ee52f1fa3aca181a38b

        return null;
    }
};

const getTokenInformation = async (req, res) => {
    try {
        const decoded = jwt.verify(req.headers["authorization"]?.split(" ")[1], secretKey);
        
        if (typeof decoded.userid === "undefined") {
            const user = await User.findOne({refreshToken: req.headers["authorization"]?.split(" ")[1]});

            if (!user) {
<<<<<<< HEAD
                console.log("token error1");
=======
                // console.log("token error1");
>>>>>>> 75ad042e5ba3ed4c774e0ee52f1fa3aca181a38b

                return null;
            }

            const token = generateToken({
                userid: user._id,
                isPremium: user.isPremium,
                isDoctor: user.isDoctor,
                isAdmin: user.isAdmin,
            });
            const refreshToken = generateRefreshToken();

            await User.findByIdAndUpdate(user._id, {
                refreshToken: refreshToken,
            });

            res.setHeader("Access_Token", token);
            res.setHeader("Refresh_Token", refreshToken);

            const payload = {
                userid: user._id,
                isPremium: user.isPremium,
                isDoctor: user.isDoctor,
                isAdmin: user.isAdmin,
            };

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
<<<<<<< HEAD
        console.error("token error2");
=======
        // console.error("token error2");
        // console.error(error);
>>>>>>> 75ad042e5ba3ed4c774e0ee52f1fa3aca181a38b

        return null;
    }
};

module.exports = {generateToken, generateRefreshToken, refreshToken, getTokenInformation};