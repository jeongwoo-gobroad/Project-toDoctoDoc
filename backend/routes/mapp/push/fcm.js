const fcm = require("firebase-admin");
const serviceAccount = require("../../../_secrets/firebase/todoctodoc-firebase-adminsdk.json");

const connectFCM = async() => {
    try {
        await fcm.initializeApp({credential: fcm.credential.cert(serviceAccount)});
        console.log("FCM connected");
    } catch (error) {
        console.error(error, "errorAtConnectFCM");

        return;
    }
};

module.exports = connectFCM;