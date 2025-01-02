const ifLoggedInThenProceed = (req, res, next) => {
    if (req.session && req.session.user) {
        next();
    } else {
        res.redirect('/login');

        return;
    }
};

const ifNotLoggedInThenProceed = (req, res, next) => {
    if (!req.session || !req.session.user) {
        next();
    } else {
        res.redirect("/");

        return;
    }
};

const ifNotLoggedInThenRedirectToLoginPage = (req, res) => {
    if (!req.session || !req.session.user) {
        res.redirect("/login");

        return;
    }
};

const ifLoggedInThenRedirectToMainPage = (req, res) => {
    if (req.session && req.session.user) {
        res.redirect("/");

        return;
    }
};

const isLoggedIn = (req, res) => {
    if (req.session && req.session.user) {
        return true;
    }

    return false;
};

const isDoctor = (req, res) => {
    if (req.session && req.session.isDoctor) {
        return true;
    }

    return false;
};

const isAdmin = (req, res) => {
    if (req.session && req.session.isAdmin) {
        return true;
    }

    return false;
};

const isDoctorThenProceed = (req, res, next) => {
    if (req.session && req.session.isDoctor) {
        next();
    } else {
        res.redirect("/");

        return;
    }
};

const isAdminThenProceed = (req, res, next) => {
    if (req.session && req.session.isAdmin) {
        next();
    } else {
        res.redirect("/");

        return;
    }
};

const errorOccured = (err) => {
    console.log(err);

    return;
};

module.exports = {
    ifLoggedInThenProceed, ifNotLoggedInThenProceed, ifLoggedInThenRedirectToMainPage, 
    ifNotLoggedInThenRedirectToLoginPage, isLoggedIn, isDoctor, isAdmin, isDoctorThenProceed, isAdminThenProceed,
    errorOccured,
};