const express = require('express');
const { checkIfLoggedIn } = require('../../checkingMiddleWare');
const Schedule = require('../../../../models/Schedule');
const returnResponse = require('../../standardResponseJSON');
const UserSchema = require('../../../../models/User');
const mongoose = require('mongoose');
const initSchedule = require('../../../../scheduleManagement/initialize');
const User = mongoose.model('User', UserSchema);
const router = express.Router();

router.post(["/manage"],
    checkIfLoggedIn,
    async (req, res, next) => {
        let {myList} = req.body;

        try {
            myList = JSON.parse(myList);

            // console.log(myList);

            const user = await User.findById(req.userid);

            if (!user.schedule) {
                await initSchedule(req.userid, false, false);
            }

            const mySchedule = await Schedule.findOne({userid: req.userid, isDoctor: false, isCounselor: false});

            mySchedule.availableTime = myList;

            await mySchedule.save();

            res.status(200).json(returnResponse(false, "userScheduleSaved", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtUserScheduleManage", "-"));

            console.error(error, "errorAtUserScheduleManage");

            return;
        }
    }
);

router.get(["/mine"], 
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const mySchedule = await Schedule.findOne({userid: req.userid, isDoctor: false, isCounselor: false});

            if (!mySchedule) {
                res.status(201).json(returnResponse(false, "noScheduleSetYet", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "yourSchedule", mySchedule));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtUserScheduleGet", "-"));

            console.error(error, "errorAtUserScheduleGet");

            return;
        }
    }
);

module.exports = router; 