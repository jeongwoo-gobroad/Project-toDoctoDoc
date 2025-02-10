const mongoose = require("mongoose");

const AccountLimitCount_doctor = new mongoose.Schema({
    dailySummationDate: {
        type: Date,
        required: true,
        default: Date.now,
    },
    dailySummationCount: {
        type: Number,
        required: true,
        default: 0,
    },
    dailyPatientStateSummationDate: {
        type: Date,
        required: true,
        default: Date.now,
    },
    dailyPatientStateSummationCount: {
        type: Number,
        required: true,
        default: 0,
    }
});

module.exports = AccountLimitCount_doctor;