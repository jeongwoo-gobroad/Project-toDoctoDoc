const express = require('express');
const { checkIfLoggedIn, isDoctorThenProceed } = require('../../../../checkingMiddleWare');
const returnResponse = require('../../../../standardResponseJSON');
const Schedule = require('../../../../../../models/Schedule');
const Doctor = require('../../../../../../models/Doctor');
const initSchedule = require('../../../../../../scheduleManagement/initialize');
const router = express.Router();

router.post(["/manage"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        let {myList} = req.body;

        try {
            myList = JSON.parse(myList);

            const doctor = await Doctor.findById(req.userid);

            if (!doctor.schedule) {
                await initSchedule(req.userid, true, false);
            }

            const mySchedule = await Schedule.findOne({userid: req.userid, isDoctor: true, isCounselor: false});

            mySchedule.availableTime = myList;

            await mySchedule.save();

            res.status(200).json(returnResponse(false, "doctorScheduleSaved", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDoctorScheduleManage", "-"));

            console.error(error, "errorAtDoctorScheduleManage");

            return;
        }
    }
);

router.get(["/mine"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const mySchedule = await Schedule.findOne({userid: req.userid, isDoctor: true, isCounselor: false});

            if (!mySchedule) {
                res.status(201).json(returnResponse(false, "noScheduleSetYet", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "yourSchedule", mySchedule));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDoctorScheduleGET", "-"));

            console.error(error, "errorAtDoctorScheduleGET");

            return;
        }
    }
);

module.exports = router;