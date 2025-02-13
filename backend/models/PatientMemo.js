const mongoose = require("mongoose");

const PatientMemoSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User',
    },
    doctor: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Doctor',
    },
    color: {
        type: Number,
        default: 0,
    },
    memo: {
        type: String,
    },
    aiSummary: {
        type: String,
    },
    details: {
        type: String,
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("PatientMemo", PatientMemoSchema);