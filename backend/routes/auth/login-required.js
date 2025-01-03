const jwt = require('jsonwebtoken');

const loginRequired = (req, res, next) => {
    const userToken = req.headers["authorization"]?.split(" ")[1];

    if (!userToken || userToken === "null") {
        console.error("허가되지 않은 접근");

        res.status(401).json({
            error: true,
            result: "forbidden-approach",
            content: "허가되지 않은 접근입니다."
        });

        return;
    }

    try {
        const secretKey = process.env.JWT_SECRET;
        const jwtDecoded = jwt.verify(userToken, secretKey);

        const userid = jwtDecoded.userid;
        const isPremium = jwtDecoded.isPremium;
        const isDoctor = jwtDecoded.isDoctor;
        const isAdmin = jwtDecoded.isAdmin;

        req.userid = userid;
        req.isPremium = isPremium;
        req.isDoctor = isDoctor;
        req.isAdmin = isAdmin;

        next();
    } catch(error) {
        res.status(401).json({
            error: true,
            result: "forbidden-approach",
            content: "허가되지 않은 접근입니다."
        });

        return;
    }
};

module.exports = loginRequired;