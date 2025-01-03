const mongoose = require("mongoose");
const AddressSchema = require("./Address");
const { refreshToken } = require("../routes/auth/jwt");

const DoctorSchema = new mongoose.Schema({
    id: {
        type: String,
        required: true,
        unique: true,
    },
    name: {
        type: String, 
        default: "anonymous",
    },
    accountCreatedAt: {
        type: Date,
        default: Date.now(),
    },
    password: {
        type: String,
        required: true,
    },
    personalID: {
        type: String,
        required: true,
        unique: true,
    },
    doctorID: {
        type: String,
        required: true,
        unique: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    address: {
        type: AddressSchema,
        required: true,
    },
    phone: {
        type: String,
        required: true,
    },
    chats: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Chat'
    }],
    isVerified: {
        type: Boolean,
        required: true,
    },
    refreshToken: {
        type: String,
    },
});

module.exports = mongoose.model("Doctor", DoctorSchema);