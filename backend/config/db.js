const mongoose = require("mongoose");
require("dotenv").config({path: "../secrets/dotenv"});

const connectDB = async () => {
    try {
        const connect = await mongoose.connect(process.env.MONGODB_URI);
        console.log(`DB Connected: ${connect.connection.host}`);
    } catch (error) {
        console.error(error, "errorAtConnectingDB");
    }
};

module.exports = connectDB;