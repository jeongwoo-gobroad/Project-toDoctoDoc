const express = require("express");
const { checkIfLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const returnResponse = require("../../standardResponseJSON");
const PatientMemo = require("../../../../models/PatientMemo");
const router = express.Router();

router.get(["/list"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const memos = await PatientMemo.find({doctor: req.userid}, '-memo').populate({
                path: 'user',
                select: 'usernick'
            });

            res.status(200).json(returnResponse(false, "memoList", memos));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtPatientMemoListing", "-"));

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

            if (!memo) {
                res.status(401).json(returnResponse(true, "noSuchMemo", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "memo", memo));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtPatientMemo", "-"));

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
            const {pid, color, memo} = req.body;

            const aMemo = await PatientMemo.create({
                user: pid,
                doctor: req.userid,
                color: color,
                memo: memo
            });

            res.status(200).json(returnResponse(false, "memoCreated", {memoId: aMemo._id}));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtPatientMemo", "-"));

            console.error(error, "errorAtPatientMemo");

            return;
        }
    }
);

router.patch(["/edit/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const {color, memo} = req.body;

            const aMemo = await PatientMemo.findById(req.params.id);

            if (!aMemo) {
                res.status(401).json(returnResponse(true, "noSuchMemo", "-"));

                return;
            }

            aMemo.color = color;
            aMemo.memo = memo;
            aMemo.updatedAt = Date.now();

            await aMemo.save();

            res.status(200).json(returnResponse(false, "memoEdited", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtPatientMemo", "-"));

            console.error(error, "errorAtPatientMemo");

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

            if (!memo) {
                res.status(401).json(returnResponse(true, "noSuchMemo", "-"));

                return;
            }

            await PatientMemo.findByIdAndDelete(req.params.id);

            res.status(200).json(returnResponse(false, "memoDeleted", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtPatientMemo", "-"));

            console.error(error, "errorAtPatientMemo");

            return;
        }
    }
);

module.exports = router;