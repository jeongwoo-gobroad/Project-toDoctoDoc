const mongoose = require("mongoose");
const { refreshToken } = require("../routes/auth/jwt");

const AdminSchema = new mongoose.Schema({
    id: {
        type: String,
        required: true,
        unique: true,
    },
    usernick: {
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
    email: {
        type: String,
        required: true,
        unique: true,
    },
    isVerified: {
        type: Boolean,
        required: true
    },
    refreshToken: {
        type: String,
    },
});

module.exports = mongoose.model('Admin', AdminSchema);