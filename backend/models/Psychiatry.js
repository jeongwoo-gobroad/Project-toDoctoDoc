const mongoose = require("mongoose");
const AddressSchema = require("./Address");

const Psychiatry_Schema = new mongoose.Schema({
    name: {
        type: String, 
        default: "anonymous",
    },
    isPremiumPsy: {
        type: Boolean,
        default: false,
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
        default: 4,
    },
    reviews: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Review'
    }],
    psyProfileImage: [{
        type: String,
    }],
    doctors: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctor',
    }],
    times: [{
        openTime: { /* xx:xx ~ xx:xx 에서 xx:xx/xx:xx형식으로 저장한다. */
            type: String, // Number가 아닌 String!
        },
        breakTime: { /* xx:xx ~ xx:xx 에서 xx:xx/xx:xx형식으로 저장한다. */
            type: String, // Number가 아닌 String!
        },
    }],
});

module.exports = mongoose.model("Psychiatry", Psychiatry_Schema);