const mongoose = require("mongoose");

const FeedbackSchema = new mongoose.Schema({
    rating: {
        type: Number,
        default: 2,
    },
    content: {
        type: String
    },
});

const AppointmentSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    doctor: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctor',
        required: true,
    },
    psyId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Psychiatry',
        required: true,
    },
    appointmentTime: {
        type: Date,
        default: Date.now,
    },
    appointmentLength: {
        type: Number,
        default: 10
    },
    appointmentCreatedAt: { 
        type: Date,
        default: Date.now,
    },
    appointmentEditedAt: {
        type: Date,
        default: Date.now,
    },
    isAppointmentApproved: {
        type: Boolean,
        default: false
    },
    hasAppointmentDone: {
        type: Boolean,
        default: false,
    },
    hasFeedbackDone: {
        type: Boolean,
        default: false,
    },
    feedback: {
        type: FeedbackSchema,
    },
    chatId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Chat',
        required: true,
    },
});

module.exports = mongoose.model("Appointment", AppointmentSchema);