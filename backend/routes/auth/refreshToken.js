const jwt = require('jsonwebtoken');
const {refreshToken} = require('./jwt');

const refreshJWTMiddleware = (req, res, next) => {
    const token = req.headers["authorization"]?.split(" ")[1];

    if (token) {
        const newToken = refreshToken(token);

        if (newToken) {
            res.cookie('token', newToken, {httpOnly: true, maxAge: 10800000});
        }
    }

    next();
};

module.exports = refreshJWTMiddleware;