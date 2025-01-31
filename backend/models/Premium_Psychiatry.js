const mongoose = require("mongoose");
const AddressSchema = require("./Address");

const Premium_Psychiatry_Schema = new mongoose.Schema({
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
    stars: {
        type: Number,
        default: 5,
    },
    reviews: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Review'
    }],
});

module.exports = mongoose.model("Premium_Psychiatry", Premium_Psychiatry_Schema);