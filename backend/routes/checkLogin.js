const { getTokenInformation_web } = require("./web_auth/jwt_web");
const Doctor = require("../models/Doctor");
const Admin = require("../models/Admin");
const UserSchema = require("../models/User");
const mongoose = require("mongoose");
const User = mongoose.model("User", UserSchema);

const ifLoggedInThenProceed = async (req, res, next) => {
    const rest = await getTokenInformation_web(req, res);

    if (rest) {
        if (!req.session.user && !rest.isDoctor && !rest.isAdmin) {
            req.session.user = await User.findById(rest.userid);
        } else if (!req.session.user && rest.isDoctor) {
            req.session.user = await Doctor.findById(rest.userid);
        } else if (!req.session.user && rest.isAdmin) {
            req.session.user = await Admin.findById(rest.userid);
        }

        next();
    } else {
        res.redirect('/login');

        return;
    }
};

const ifNotLoggedInThenProceed = async (req, res, next) => {
    if (!(await getTokenInformation_web(req, res))) {
        next();
    } else {
        res.redirect("/");

        return;
    }
};

const ifNotLoggedInThenRedirectToLoginPage = async (req, res) => {
    if (!(await getTokenInformation_web(req, res))) {
        res.redirect("/login");

        return;
    }
};

const ifLoggedInThenRedirectToMainPage = async (req, res) => {
    if (await getTokenInformation_web(req, res)) {
        res.redirect("/");

        return;
    }
};

const isLoggedIn = async (req, res) => {
    const rest = await getTokenInformation_web(req, res);
    if (rest) {
        if (!req.session.user && !rest.isDoctor && !rest.isAdmin) {
            req.session.user = await User.findById(rest.userid);
        } else if (!req.session.user && rest.isDoctor) {
            req.session.user = await Doctor.findById(rest.userid);
        } else if (!req.session.user && rest.isAdmin) {
            req.session.user = await Admin.findById(rest.userid);
        }

        return true;
    }

    return false;
};

const isDoctor = async (req, res) => {
    const rest = await getTokenInformation_web(req, res);

    if (rest && rest.isDoctor) {
        return true;
    }

    return false;
};

const isAdmin = async (req, res) => {
    const rest = await getTokenInformation_web(req, res);

    if (rest && rest.isAdmin) {
        return true;
    }

    return false;
};

const isDoctorThenProceed = async (req, res, next) => {
    const rest = await getTokenInformation_web(req, res);

    if (rest && rest.isDoctor) {
        next();
    } else {
        res.redirect("/");

        return;
    }
};

const isAdminThenProceed = async (req, res, next) => {
    const rest = await getTokenInformation_web(req, res);

    if (rest && rest.isAdmin) {
        next();
    } else {
        res.redirect("/");

        return;
    }
};

const errorOccured = (err) => {
    console.error(err);

    return;
};

module.exports = {
    ifLoggedInThenProceed, ifNotLoggedInThenProceed, ifLoggedInThenRedirectToMainPage, 
    ifNotLoggedInThenRedirectToLoginPage, isLoggedIn, isDoctor, isAdmin, isDoctorThenProceed, isAdminThenProceed,
    errorOccured,
};