const mongoose = require("mongoose");
const AddressSchema = require("./Address");

const Psychiatry_Schema = new mongoose.Schema({
    name: {
        type: String, 
        default: "anonymous",
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
    updatedAt: {
        type: Date,
        default: Date.now
    },
    place_id: {
        type: String,
        required: true
    },
    address: {
        type: AddressSchema,
        required: true,
    },
    phone: {
        type: String,
        required: true,
    },
});

module.exports = mongoose.model("Psychiatry", Psychiatry_Schema);