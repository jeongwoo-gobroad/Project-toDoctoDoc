const express = require("express");
const returnResponse = require("../../standardResponseJSON");
const { getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const router = express.Router();
const manager = require("./multer/psyProfileImageUploader");
const Psychiatry = require("../../../../models/Psychiatry");
const psyManagement = require("./psyManagement/functions");
const Doctor = require("../../../../models/Doctor");

router.get(['/myPsyInfo'],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const doctor = await Doctor.findById(req.userid);
            const psy = await Psychiatry.findById(doctor.myPsyID);

            if (!psy) {
                res.status(401).json(returnResponse(true, "noSuchPsyOrNoPsyRegistered", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "yourPsyInfo", psy));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtMyPsyInfo", "-"));

            console.error(error, "errorAtMyPsyInfo");

            return;
        }
    }
);

router.patch(['/myPsyInfo'],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const {name, address, phone} = req.body;

        try {
            const doctor = await Doctor.findById(req.userid);
            const psy = await Psychiatry.findById(doctor.myPsyID);

            if (!psy) {
                res.status(401).json(returnResponse(true, "noSuchPsyOrNoPsyRegistered", "-"));

                return;
            }

            psy.name = name;
            psy.address = address;
            psy.phone = phone;
            psy.updatedAt = Date.now();

            await psy.save();

            res.status(200).json(returnResponse(false, "psyInfoEdited", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtMyPsyInfo", "-"));

            console.error(error, "errorAtMyPsyInfo");

            return;
        }
    }
);

router.post(['/upload/:psyId'],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const psy = await Psychiatry.findById(req.params.psyId);

            if (!psy) {
                res.status(401).json(returnResponse(true, "noSuchPsy", "-"));
            }

            if (!psy.doctors.toString().includes(user.userid)) {
                res.status(402).json(returnResponse(true, "notYourPsy", "-"));
            }

            req.psyId = psy._id;

            next();
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtPsyUploadMiddleware", "-"));

            console.error(error, "errorAtPsyUploadMiddleware");

            return;
        }
    },  
    manager.multer.array('files', 10),
    manager.upload,
    async (req, res, next) => {
        const baseURI = process.env.GCP_DOCTOR_URI;

        try {
            const psy = await Psychiatry.findById(req.params.psyId);

            for (const fileName of req.myFiles) {
                psy.psyProfileImage.push(baseURI + fileName);
            }

            await psy.save();

            res.status(200).json(returnResponse(false, "psyProfileImageUploaded", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtPsyProfileImageUpload", "-"));

            console.error(error, "errorAtPsyProfileImageUpload");

            return;
        }
    }
);

router.delete(['/delete/:imgName'],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const {psyId} = req.body;
        const user = await getTokenInformation(req, res);

        try {
            if (await psyManagement.doesOwnPsy(psyId, user.userid)) {
                psyManagement.findByFileNameAndDelete(psyId, req.params.imgName);
    
                res.status(200).json(returnResponse(false, "psyProfileImageDeleted", "-"));
    
                return;
            }

            res.status(401).json(returnResponse(true, "notYourPsyOrErrorAtDoesOwnPsy", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtPsyProfileImageDelete", "-"));

            console.error(error, "errorAtPsyProfileImageDelete");

            return;
        }
    }
);

module.exports = router;