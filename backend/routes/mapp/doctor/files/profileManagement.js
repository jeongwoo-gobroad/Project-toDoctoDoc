const express = require("express");
const returnResponse = require("../../standardResponseJSON");
const { getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const router = express.Router();
const Doctor = require("../../../../models/Doctor");
const multer = require("multer");
const storage = multer.memoryStorage();
const upload = multer({storage: storage});

router.post(['/upload'],
    checkIfLoggedIn,
    isDoctorThenProceed,
    upload.single('profileImage'),
    async (req, res, next) => {

    }
);

module.exports = router;