const mongoose = require("mongoose");

const AccountLimitCount = new mongoose.Schema({
    dailyRequestDate: {
        type: Date,
        required: true
    },
    dailyRequestCount: {
        type: Number,
        required: true,
    },
    dailyChatDate: {
        type: Date,
        required: true
    },
    dailyChatCount: {
        type: Number,
        required: true,
    }
});

module.exports = AccountLimitCount;