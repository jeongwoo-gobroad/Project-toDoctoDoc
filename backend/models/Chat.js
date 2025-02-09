const mongoose = require("mongoose");

const BubbleSchema = new mongoose.Schema({
    role: {
        type: String,
        required: true
    },
    message: {
        type: String,
        required: true
    },
    createdAt: {
        type: Date
    },
    autoIncrementId: {
        type: Number,
    },
});

const ChatSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User',
        unique: false,
    },
    doctor: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Doctor',
        unique: false,
    },
    chatList: [{
        type: BubbleSchema
    }],
    date: {
        type: Date,
        default: Date.now,
    },
    appointment: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Appointment',
    },
    isBannedByUser: {
        type: Boolean,
        default: false,
    },
    isBannedByDoctor: {
        type: Boolean,
        default: false,
    },
});

module.exports = mongoose.model("Chat", ChatSchema);