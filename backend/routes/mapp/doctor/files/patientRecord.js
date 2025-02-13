const express = require("express");
const { checkIfLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const returnResponse = require("../../standardResponseJSON");
const PatientMemo = require("../../../../models/PatientMemo");
const router = express.Router();

router.get(["/exists/:uid"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const memo = await PatientMemo.findOne({doctor: req.userid, user:req.params.uid}, '-memo -aiSummary -details');

            if (!memo) {
                res.status(201).json(returnResponse(false, "memoDoesNotExist", {exists: false}));

                return;
            }

            res.status(200).json(returnResponse(false, "memoExists", {exists: true, memoId: memo._id}));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtPatientMemoListing", "-"));

            console.error(error, "errorAtPatientMemoListing");

            return;
        }
    }
);

router.get(["/list"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const memos = await PatientMemo.find({doctor: req.userid}, '-memo -aiSummary -details').populate({
                path: 'user',
                select: 'usernick'
            });

            res.status(200).json(returnResponse(false, "memoList", memos));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtPatientMemoListing", "-"));

            console.error(error, "errorAtPatientMemoListing");

            return;
        }
    }
);

router.get(["/details/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const memo = await PatientMemo.findById(req.params.id).populate({
                path: 'user',
                select: 'usernick'
            });

            if (!memo || memo.doctor != req.userid) {
                res.status(401).json(returnResponse(true, "noSuchMemoOrNotYourMemo", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "memo", memo));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtPatientMemo", "-"));

            console.error(error, "errorAtPatientMemo");

            return;
        }
    }
);

router.post(["/write"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const {pid, color, memo, details} = req.body;

            const aMemo = await PatientMemo.create({
                user: pid,
                doctor: req.userid,
                color: color,
                memo: memo,
                details: details,
            });

            res.status(200).json(returnResponse(false, "memoCreated", {memoId: aMemo._id}));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtPatientMemo", "-"));

            console.error(error, "errorAtPatientMemo");

            return;
        }
    }
);

router.patch(["/editMemo/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const {color, memo} = req.body;

            const aMemo = await PatientMemo.findById(req.params.id);

            if (!aMemo || aMemo.doctor != req.userid) {
                res.status(401).json(returnResponse(true, "noSuchMemoOrNotYourMemo", "-"));

                return;
            }

            if (memo.length > 500) {
                res.status(400).json(returnResponse(true, "lengthTooLong", "-"));

                return;
            }

            await PatientMemo.findByIdAndUpdate(req.params.id, {
                color: color,
                memo: memo,
                updatedAt: Date.now(),
            });

            res.status(200).json(returnResponse(false, "memoEdited", "-"));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtPatientMemo", "-"));

            console.error(error, "errorAtPatientMemo");

            return;
        }
    }
);

router.patch(["/editDetails/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const {details} = req.body;

            const aMemo = await PatientMemo.findById(req.params.id);

            if (!aMemo || aMemo.doctor != req.userid) {
                res.status(401).json(returnResponse(true, "noSuchMemoOrNotYourMemo", "-"));

                return;
            }

            await PatientMemo.findByIdAndUpdate(req.params.id, {
                updatedAt: Date.now(),
                details: details
            });

            res.status(200).json(returnResponse(false, "detailEdited", "-"));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtPatientDetail", "-"));

            console.error(error, "errorAtPatientDetail");

            return;
        }
    }
);

router.delete(["/delete/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const memo = await PatientMemo.findById(req.params.id);

            if (!memo || memo.doctor != req.userid) {
                res.status(401).json(returnResponse(true, "noSuchMemoOrNotYourMemo", "-"));

                return;
            }

            await PatientMemo.findByIdAndDelete(req.params.id);

            res.status(200).json(returnResponse(false, "memoDeleted", "-"));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtPatientMemo", "-"));

            console.error(error, "errorAtPatientMemo");

            return;
        }
    }
);

module.exports = router;