const mongoose = require("mongoose");

const ReviewSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId, 
        required: true,
    },
    createdAt: {
        type: Date,
        default: Date.now(),
    },
    updatedAt: {
        type: Date,
        default: Date.now()
    },
    place_id: {
        type: String,
        required: true
    },
    stars: {
        type: Number,
        default: 4,
    },
    content: {
        type: String,
    },
});

module.exports = mongoose.model("Review", ReviewSchema);