const express = require("express");
const returnResponse = require("../../standardResponseJSON");
const { getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const router = express.Router();
const Doctor = require("../../../../models/Doctor");
const upload = require("./multer/multer");

router.post(['/upload'],
    // checkIfLoggedIn,
    // isDoctorThenProceed,
    upload.single('file'),
    async (req, res, next) => {
        console.log("img uploaded: ", JSON.stringify(req.file));

        return;
    }
);

module.exports = router;