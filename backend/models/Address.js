const mongoose = require("mongoose");

const AddressSchema = new mongoose.Schema({
    postcode: {
        type: String,
        required: true,
    },
    address: {
        type: String,
        required: true,
    },
    detailAddress: {
        type: String,
        required: true,
    },
    extraAddress: {
        type: String,
        required: true,
    },
    longitude: {
        type: mongoose.Schema.Types.Double,
        required: true,
    },
    latitude: {
        type: mongoose.Schema.Types.Double,
        required: true,
    }
});

module.exports = AddressSchema;