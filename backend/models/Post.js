const mongoose = require("mongoose");
const UserSchema = require("./User");

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
        default: Date.now(),
    },
    editedAt: {
        type: Date,
        default: Date.now(),
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
});

module.exports = mongoose.model("Post", PostSchema);