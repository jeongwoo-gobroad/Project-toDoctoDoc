const mongoose = require("mongoose");

const CurateSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User',
    },
    deepCurate: {
        type: String,
    },
    posts: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Post'
    }],
    ai_chats: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'AIChat'
    }],
    comments: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Comment'
    }],
    date: {
        type: Date,
        required: true,
        default: Date.now
    },
    createdAt: {
        type: Date,
        required: true,
        default: Date.now
    },
    isNotRead: {
        type: Boolean,
        default: false,
    },
    isPublic: {
        type: Boolean,
        default: false,
    },
    ifNotPublicOpenedTo: [{
        type: String
    }]
});

module.exports = mongoose.model("Curate", CurateSchema);