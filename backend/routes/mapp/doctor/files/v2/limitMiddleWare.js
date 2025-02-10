const returnResponse = require('../../../standardResponseJSON');
const Doctor = require('../../../../../models/Doctor');

const checkIfDailySummationLimitNotExceeded = async (req, res, next) => {
    try {
        const doctor = await Doctor.findById(req.userid);

        const limits = doctor.limits;
        const current = new Date();

        if (limits.dailySummationDate.toLocaleDateString() !== current.toLocaleDateString()) {
            limits.dailySummationDate = current;
            limits.dailySummationCount = 0;
        }

        if (limits.dailySummationCount >= 5) {
            res.status(555).json(returnResponse(true, "exceededTaskLimit", "-"));
        } else {
            limits.dailySummationCount += 1;

            await doctor.save();

            next();

            return;
        }
    } catch (error) {
        res.status(500).json(returnResponse(true, "errorAtCheckIfDailySummationLimitNotExceeded", "-"));

        console.error(error, "errorAtCheckIfDailySummationLimitNotExceeded");

        return;
    }
};

const checkIfDailyPatientStateSummationLimitNotExceeded = async (req, res, next) => {
    try {
        const doctor = await Doctor.findById(req.userid);

        const limits = doctor.limits;
        const current = new Date();

        if (limits.dailyPatientStateSummationDate.toLocaleDateString() !== current.toLocaleDateString()) {
            limits.dailyPatientStateSummationDate = current;
            limits.dailyPatientStateSummationCount = 0;
        }

        if (limits.dailyPatientStateSummationCount >= 30) {
            res.status(555).json(returnResponse(true, "exceededTaskLimit", "-"));
        } else {
            limits.dailyPatientStateSummationCount += 1;

            await doctor.save();

            next();

            return;
        }
    } catch (error) {
        res.status(500).json(returnResponse(true, "errorAtCheckIfDailyPatientStateSummationLimitNotExceeded", "-"));

        console.error(error, "errorAtCheckIfDailyPatientStateSummationLimitNotExceeded");

        return;
    }
};

module.exports = {checkIfDailySummationLimitNotExceeded, checkIfDailyPatientStateSummationLimitNotExceeded};