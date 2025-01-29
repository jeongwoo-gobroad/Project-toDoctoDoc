const mongoose = require("mongoose");

const ProfileImageSchema = new mongoose.Schema({
    image: {
        data: Buffer,
        contentType: String,
    }
});

module.exports = mongoose.model('ProfileImage', ProfileImageSchema);