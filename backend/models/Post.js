const mongoose = require("mongoose");

const PostSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
    },
    details: {
        type: String,
        required: true,
    },
    additional_material: {
        type: String,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
    editedAt: {
        type: Date,
        default: Date.now,
    },
    tag: {
        type: String,
    },
    user: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User',
        unique: false,
    },
    views: {
        type: Number,
        default: 0,
    },
});

module.exports = mongoose.model("Post", PostSchema);