const express = require('express');
const { checkIfLoggedIn } = require('../../checkingMiddleWare');
const returnResponse = require('../../standardResponseJSON');
const router = express.Router();
const UserSchema = require("../../../../models/User");
const mongoose = require("mongoose");
const Curate = require('../../../../models/Curate');
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

module.exports = router; 