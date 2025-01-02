const mongoose = require("mongoose");

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
    }
});

module.exports = mongoose.model('Admin', AdminSchema);