const mongoose = require("mongoose");

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
    appointmentTime: {
        type: Date,
        default: Date.now,
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
    }
});

module.exports = mongoose.model("Appointment", AppointmentSchema);