const mongoose = require("mongoose");

const CommentSchema = new mongoose.Schema({
    doctor: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Doctor',
    },
    content: {
        type: String,
        required: true,
    },
    date: {
        type: Date,
        required: true,
        default: Date.now()
    },
    originalID: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Curate',
    },
});

module.exports = mongoose.model("Comment", CommentSchema);