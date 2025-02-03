const express = require("express");
const returnResponse = require("../../standardResponseJSON");
const { getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const router = express.Router();
const Doctor = require("../../../../models/Doctor");
const manager = require("./multer/profileImageUploader");
const path = require("path");
const deletePreviousImage = require("./multer/profileImageDeleter");

router.post(['/upload'],
    checkIfLoggedIn,
    isDoctorThenProceed,
    deletePreviousImage,
    manager.multer.single('file'),
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const baseURI = process.env.GCP_DOCTOR_URI;

        try {
            req.userid = user.userid;

            await manager.upload(req);

            await Doctor.findByIdAndUpdate(user.userid, {
                myProfileImage: baseURI + req.myFileName
            });

            res.status(200).json(returnResponse(false, "doctorProfileImageUploaded", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDoctorProfileImageUpload", "-"));

            console.error(error, "errorAtDoctorProfileImageUpload");

            return;
        }
    }
);

module.exports = router;