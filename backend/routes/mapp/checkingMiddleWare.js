const { getTokenInformation } = require("../auth/jwt");
const returnResponse = require("./standardResponseJSON");

const checkIfLoggedIn = (req, res, next) => {
    if (getTokenInformation(req, res)) {
        next();

        return;
    }

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

const checkIfNotLoggedIn = (req, res, next) => {
    if (getTokenInformation(req, res)) {
        res.status(401).json(returnResponse(true, "already_logged_in", "이미 로그인 되어 있습니다."));

        return;
    }

    next();

    return;
};

const isDoctorThenProceed = (req, res, next) => {
    const rest = getTokenInformation(req, res);

    if (rest) {
        if (rest.isDoctor) {
            next();

            return;
        } else {
            res.status(401).json(returnResponse(true, "not_a_doctor", "의사가 아닙니다."));

            return;
        }
    } 

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

const ifPremiumThenProceed = (req, res, next) => {
    const rest = getTokenInformation(req, res);

    if (rest) { 
        if (rest.isPremium) {
            next();

            return;
        } else {
            res.status(401).json(returnResponse(true, "not_premium_account", "프리미엄 계정이 아닙니다."));

            return;
        }
    } 

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

module.exports = {checkIfLoggedIn, checkIfNotLoggedIn, isDoctorThenProceed, ifPremiumThenProceed};