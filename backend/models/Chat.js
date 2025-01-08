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
        default: Date.now(),
    },
});

module.exports = mongoose.model("Chat", ChatSchema);