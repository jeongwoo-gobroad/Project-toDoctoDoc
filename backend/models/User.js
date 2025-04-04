const mongoose = require("mongoose");
const AddressSchema = require("./Address");
const AccountLimitCountSchema = require("./AccountLimitCount");

const UserSchema = new mongoose.Schema({
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
        default: Date.now,
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
    address: {
        type: AddressSchema,
        required: true,
    },
    limits: {
        type: AccountLimitCountSchema,
        required: true,
    },
    isPremium: {
        type: Boolean,
        required: true,
        default: false,
    },
    posts: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Post'
    }],
    ai_chats: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'AIChat',
    }],
    curates: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Curate',
    }],
    deepCurates: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'DeepCurate',
    }],
    chats: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Chat',
    }],
    reviews: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Review'
    }],
    appointments: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Appointment'
    }],
    deviceIds: [{
        type: String,
    }],
    bannedTags: [{
        type: String,
    }],
    refreshToken: {
        type: String,
    },
    recentCurateDate: {
        type: Date,
    },
    recentCurate: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Curate',
    },
    visitedPsys: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Psychiatry',
    }],
    schedule: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Schedule',
    }
});

module.exports = UserSchema;