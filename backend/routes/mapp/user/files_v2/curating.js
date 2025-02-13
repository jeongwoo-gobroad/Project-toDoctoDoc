const express = require('express');
const { checkIfLoggedIn } = require('../../checkingMiddleWare');
const returnResponse = require('../../standardResponseJSON');
const router = express.Router();
const UserSchema = require("../../../../models/User");
const mongoose = require("mongoose");
const Curate = require('../../../../models/Curate');
const sortAroundDoctorListsByScoreWeight = require('../../../../algorithms/sortAroundDoctorLists');
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

            res.status(403).json(returnResponse(true, "errorAt/user/files/curating.js:list GET", "-"));

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

module.exports = router; 