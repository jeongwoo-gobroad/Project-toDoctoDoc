const OpenAI = require('openai');
const { zodResponseFormat } = require('openai/helpers/zod');
const express = require('express');
const { checkIfLoggedIn, isDoctorThenProceed } = require('../../../../checkingMiddleWare');
const returnResponse = require('../../../../standardResponseJSON');
const Appointment = require('../../../../../../models/Appointment');
const {checkIfDailySummationLimitNotExceeded, checkIfDailyPatientStateSummationLimitNotExceeded} = require('../limitMiddleWare');
const moment = require('moment');
const PatientMemo = require('../../../../../../models/PatientMemo');
const dailyScheduleSchema = require('../jsonSchema/aiMemo');
const Doctor = require('../../../../../../models/Doctor');

const router = express.Router();

router.get(["/dailyLimit"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const doctor = await Doctor.findById(req.userid);

            res.status(200).json(returnResponse(false, "leftDailyLimit", doctor.limits));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtDailyLimit", "-"));

            console.error(error, "errorAtDailyLimit");

            return;
        }
    }
);

router.post(["/dailySummation"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    // checkIfDailySummationLimitNotExceeded,
    async (req, res, next) => {
        try {
            const today = moment().startOf('day');
            const tomorrow = moment().endOf('day');
            const inputData = [];

            const appointments = await Appointment.find({$and: [
                {doctor: req.userid},
                {appointmentTime: {$gte: today, $lte: tomorrow}}
            ]}).populate('user', 'usernick');

            for (const appointment of appointments) {
                const memo = await PatientMemo.findOne({user: appointment.user, doctor: appointment.doctor});
                inputData.push({
                    appointmentStartAt: appointment.appointmentTime,
                    appointmentEndAt: appointment.appointmentEndAt,
                    patientName: appointment.user.usernick,
                    patientMemo: memo.memo
                });
            }

            const openai = new OpenAI({
                apiKey: process.env.OPENAI_KEY,
            });

            const completion = await openai.beta.chat.completions.parse({
                "model": "gpt-4o",
                "store": false,
                "messages": [
                    {
                        "role": "developer",
                        "content": "너는 전문 심리 상담사이고, 각 환자의 이름과 그에 따른 메모의 간략한 요약을 이야기 해 줘야 해."
                    },
                    {
                        "role": "user",
                        "content": JSON.stringify(inputData)
                    }
                ],
                "response_format": zodResponseFormat(dailyScheduleSchema, "schedule")
            });

            const result = completion.choices[0].message.parsed;

            res.status(200).json(returnResponse(false, "dailySummation", result));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtDailySummation", "-"));

            console.error(error, "errorAtDailySummation");

            return;
        }
    }
);

module.exports = router;