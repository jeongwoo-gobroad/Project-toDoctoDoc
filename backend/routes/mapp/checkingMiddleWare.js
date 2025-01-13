const Doctor = require("../../models/Doctor");
const { getTokenInformation } = require("../auth/jwt");
const returnResponse = require("./standardResponseJSON");

const checkIfLoggedIn = async (req, res, next) => {
    const rest = await getTokenInformation(req, res);

    if (rest && rest !== -1) {
        next();

        return;
    } else if (rest && rest === -1) {
        console.log("Expired token");

        res.status(419).json(returnResponse(true, "token_expired", "토큰이 만료되었습니다."));

        return;
    }

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

const checkIfNotLoggedIn = async (req, res, next) => {
    if (await getTokenInformation(req, res)) {
        res.status(401).json(returnResponse(true, "already_logged_in", "이미 로그인 되어 있습니다."));

        return;
    }

    next();

    return;
};

const isDoctorThenProceed = async (req, res, next) => {
    const rest = await getTokenInformation(req, res);
    const doctor = await Doctor.findById(rest.userid);

    if (rest) {
        if (rest.isDoctor && doctor && doctor.isVerified) {
            next();

            return;
        } else if (rest.isDoctor && doctor && !doctor.isVerified) {
            res.status(601).json(returnResponse(true, "doctor_register_pending", "의사 본인 확인 절차 진행 중."));

            return;
        } else {
            res.status(600).json(returnResponse(true, "not_a_doctor", "의사가 아닙니다."));

            return;
        }
    } 

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

const ifPremiumThenProceed = async (req, res, next) => {
    const rest = await getTokenInformation(req, res);

    if (rest) { 
        if (rest.isPremium) {
            next();

            return;
        } else {
            res.status(700).json(returnResponse(true, "not_premium_account", "프리미엄 계정이 아닙니다."));

            return;
        }
    } 

    res.status(401).json(returnResponse(true, "not_logged_in", "로그인 해 주세요"));

    return;
};

const ifTokenIsNotExpriredThenProceed = async (req, res, next) => {
    const rest = await getTokenInformation(req, res);

    if (rest === -1) {
        res.status(419).json(returnResponse(true, "token_expired", "토큰이 만료되었습니다."));

        return;
    }

    next();
};

module.exports = {checkIfLoggedIn, checkIfNotLoggedIn, isDoctorThenProceed, ifPremiumThenProceed, ifTokenIsNotExpriredThenProceed};