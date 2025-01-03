const { getTokenInformation } = require("../../auth/jwt");
const returnResponse = require("../standardResponseJSON");

const checkIfLoggedIn = (req, res, next) => {
    const token = req.cookies.token;

    if (getTokenInformation(token)) {
        next();
    }

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

const isDoctorThenProceed = (req, res, next) => {
    const token = req.cookies.token;

    const res = getTokenInformation(token);

    if (res) {
        if (res.isDoctor) {
            next();
        } else {
            res.status(401).json(returnResponse(true, "not_a_doctor", "의사가 아닙니다."));
        }
    } 

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

const ifPremiumThenProceed = (req, res, next) => {
    const token = req.cookies.token;

    const res = getTokenInformation(token);

    if (res) {
        if (res.isPremium) {
            next();
        } else {
            res.status(401).json(returnResponse(true, "not_premium_account", "프리미엄 계정이 아닙니다."));
        }
    } 

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

module.exports = {checkIfLoggedIn, isDoctorThenProceed, ifPremiumThenProceed};