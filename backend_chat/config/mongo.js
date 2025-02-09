const mongoose = require("mongoose");

const connectDB = async () => {
    try {
        const connect = await mongoose.connect(process.env.MONGODB_URI);
        console.log(`DB Connected from chat server: ${connect.connection.host}`);
    } catch (error) {
        console.error(error, "errorAtConnectingDB from chat server");
    }
};

module.exports = connectDB;