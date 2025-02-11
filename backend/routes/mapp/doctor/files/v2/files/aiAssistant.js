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
    checkIfDailySummationLimitNotExceeded,
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
                if (memo && memo.memo.length > 50) {
                    inputData.push({
                        appointmentStartAt: appointment.appointmentTime,
                        appointmentEndAt: appointment.appointmentEndAt,
                        patientName: appointment.user.usernick,
                        patientMemo: memo.memo
                    });
                }
            }

            const openai = new OpenAI({
                apiKey: process.env.OPENAI_KEY,
            });

            if (inputData.length < 1) {
                res.status(401).json(returnResponse(true, "noScheduleToday", "-"));

                return;
            }

            const completion = await openai.beta.chat.completions.parse({
                "model": "gpt-4o",
                "store": false,
                "messages": [
                    {
                        "role": "developer",
                        "content": "너는 정신과 전문의를 보조 해 주는 역할이야. startFrom에는 약속 시작 시각을 ISODate 형태로 표현하고, duration에는 약속 종료 시작과 약속 시작 시각 간의 차이를 분 단위로 계산해서 넣고, 그리고 각 환자의 이름은 patientName에, 그에 따른 환자별 메모의 간략한 요약은 shortMemo에 적어서, 한국어 경어체로 이야기 해 줘야 해."
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

router.post(["/detailSummation"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    checkIfDailyPatientStateSummationLimitNotExceeded,
    async (req, res, next) => {
        const {memoId} = req.body;

        try {
            const memo = await PatientMemo.findById(memoId);

            if (!memo || memo.details.length < 100) {
                res.status(401).json(returnResponse(true, "noSuchMemoIdorDetailsTooShort", "-"));

                return;
            }

            const openai = new OpenAI({
                apiKey: process.env.OPENAI_KEY,
            });

            const completion = await openai.chat.completions.create({
                model: "gpt-4o",
                store: false,
                messages: [
                    {
                        role: "developer", content: "너는 정신과 전문의를 보조해 주는 사람이고, 내가 제시한 환자의 메모를 보고 요약본을 250자 이내의, 한국어 경어체로 제시 해 줘야 해.",
                    },
                    {
                        role: "user", content: memo.details,
                    },
                ]
            });

            const summarizedText = completion.choices[0].message.content;

            await PatientMemo.findByIdAndUpdate(memoId, {
                aiSummary: summarizedText,
            });

            res.status(200).json(returnResponse(false, "patientMemoSummation", summarizedText));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtPatientMemoSummation", "-"));

            console.error(error, "errorAtPatientMemoSummation");

            return;
        }
    }
);

module.exports = router;