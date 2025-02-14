const express = require('express');
const { checkIfLoggedIn } = require('../../checkingMiddleWare');
const returnResponse = require('../../standardResponseJSON');
const router = express.Router();
const UserSchema = require("../../../../models/User");
const mongoose = require("mongoose");
const Curate = require('../../../../models/Curate');
const sortAroundDoctorListsByScoreWeight = require('../../../../algorithms/sortAroundDoctorLists');
const { ifDailyCurateNotExceeded_v2, ifDailyCurateHasDone } = require('../../limitMiddleWare');
const returnNewCurate = require('../functions/returnNewCurate');
const Doctor = require('../../../../models/Doctor');
const User = mongoose.model("User", UserSchema);

router.get(["/list"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const {sort, amount, last_id} = req.query;
        const query = {};

        try {
            const sortOrder = parseInt(sort);
            
            if (last_id) {
                if (sortOrder === -1) { // 내림차순 정렬이라면
                    query.$and = [
                        {
                            user: req.userid
                        },
                        {
                            _id: {$lt: last_id}
                        }
                    ];
                } else { // 오름차순 정렬이라면
                    query.$and = [
                        {
                            user: req.userid
                        },
                        {
                            _id: {$gt: last_id}
                        }
                    ];
                }
            } else {
                query.user = req.userid;
            }

            const curates = await Curate.find(query).sort({createdAt: sortOrder}).limit(amount);

            res.status(200).json(returnResponse(false, "userCurateList", curates));

            return;
        } catch (error) {
            console.error(error, "errorAt/user/files/curating.js:list GET");

            res.status(500).json(returnResponse(true, "errorAt/user/files/curating.js:list GET", "-"));

            return;
        }
    }
);

router.get(["/nearbyCurating"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const {fastWeight, distWeight, starWeight, radius} = req.query;

        try {
            const user = await User.findById(req.userid);

            const list = await sortAroundDoctorListsByScoreWeight(
                fastWeight, distWeight, starWeight, user.address.longitude, user.address.latitude, radius
            );

            res.status(200).json(returnResponse(false, "returnNearbyCurating", list));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtNearbyCurating", "-"));

            console.error(error, "errorAtNearbyCurating");

            return;
        }
    }
);

router.post(["/todayCurate"],
    checkIfLoggedIn,
    ifDailyCurateNotExceeded_v2,
    async (req, res, next) => {
        try {
            let curate = null;

            if (!req.isDone) {
                curate = await returnNewCurate(req.userid);
                await User.findByIdAndUpdate(req.userid, {
                    $push: {curates: curate._id},
                    recentCurateDate: Date.now(),
                    recentCurate: curate._id,
                });
            } else {
                curate = (await User.findById(req.userid).populate('recentCurate')).recentCurate;
            }

            res.status(200).json(returnResponse(false, "todayCurateResult", curate));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtTodayCurate", "-"));

            console.error(error, "errorAtTodayCurate");

            return;
        }
    }
);

router.patch(["/showTo/:did"],
    checkIfLoggedIn,
    ifDailyCurateHasDone,
    async (req, res, next) => {
        try {
            const curateId = (await User.findById(req.userid).populate('recentCurate', '_id')).recentCurate._id;
            const doctor = await Doctor.findById(req.params.did);

            if (!doctor) {
                res.status(405).json(returnResponse(true, "noSuchDoctor", "-"));

                return;
            }
            
            await Curate.findByIdAndUpdate(curateId, {
                $push: {ifNotPublicOpenedTo: req.params.did}
            });

            res.status(200).json(returnResponse(false, "madePublicOnlyToGivenDoctor", "-"));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtShowTo", "-"));

            console.error(error, "errorAtShowTo");

            return;
        }
    }
);

router.patch(["/makePublic/:cid"],
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const curate = await Curate.findById(req.params.cid);

            if (curate.user != req.userid) {
                res.status(401).json(returnResponse(true, "notYourCurate", "-"));

                return;
            }

            if (curate.isPublic) {
                res.status(203).json(returnResponse(true, "alreadyPublic", "-"));

                return;
            }

            await Curate.findByIdAndUpdate(req.params.cid, {
                isPublic: true
            });

            res.status(200).json(returnResponse(false, "madePublicToAll", "-"));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtMakePublic", "-"));

            console.error(error, "errorAtMakePublic");

            return;
        }
    }
);

router.patch(["/makePrivate/:cid"],
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const curate = await Curate.findById(req.params.cid);

            if (curate.user != req.userid) {
                res.status(401).json(returnResponse(true, "notYourCurate", "-"));

                return;
            }

            if (!curate.isPublic) {
                res.status(203).json(returnResponse(true, "alreadyPrivate", "-"));

                return;
            }

            await Curate.findByIdAndUpdate(req.params.cid, {
                isPublic: false
            });

            res.status(200).json(returnResponse(false, "madePrivate", "-"));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtMakePrivate", "-"));

            console.error(error, "errorAtMakePrivate");

            return;
        }
    }
);

module.exports = router; 