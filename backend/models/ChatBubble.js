const mongoose = require("mongoose");

const ChatBubbleSchema = new mongoose.Schema({
    chatId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Chat',
    },
    message: {
        type: Object,
    },
    autoIncrementId: {
        type: Number,
    },
});

module.exports = mongoose.model("ChatBubble", ChatBubbleSchema);