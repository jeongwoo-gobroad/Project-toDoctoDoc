const mongoose = require("mongoose");

const AIChatSchema = new mongoose.Schema({
    title: {
        type: String,
    },
    response: [{
        type: Object, /* for flutter version */
    }],
    recentMessage: {
        type: String,
    },
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    chatCreatedAt: { 
        type: Date,
        default: Date.now,
    },
    chatEditedAt: {
        type: Date,
        default: Date.now,
    }
});

module.exports = mongoose.model("AIChat", AIChatSchema);