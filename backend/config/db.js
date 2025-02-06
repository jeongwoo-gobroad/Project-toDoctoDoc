const mongoose = require("mongoose");
const asynchandler = require("express-async-handler");
require("dotenv").config({path: "../secrets/dotenv"});

const connectDB = asynchandler(async () => {
    const connect = await mongoose.connect(process.env.MONGODB_URI);
    console.log(`DB Connected: ${connect.connection.host}`);
});

module.exports = connectDB;