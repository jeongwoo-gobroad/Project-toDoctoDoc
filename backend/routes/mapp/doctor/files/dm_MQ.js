const { default: mongoose } = require("mongoose");
const {redisClient} = require("../../../../config/redis");
const Chat = require("../../../../models/Chat");
const UserSchema = require("../../../../models/User");
const Doctor = require("../../../../models/Doctor");
const User = mongoose.model('User', UserSchema);
const request = require('request');
const jwt = require("jsonwebtoken");
const { setCacheForThreeDaysAsync, getCache, setCacheForNDaysAsync } = require("../../../../middleware/redisCaching");
const sendDMPushNotification = require("../../push/dmPush");
const {Worker} = require('worker_threads');

const chatting_doctor = async (socket, next) => {
    const token = socket.handshake.query.token;
    const roomNo = socket.handshake.query.roomNo;

    console.log("Doctor socket connected");

    try {
        const token_userid = jwt.verify(token, process.env.JWT_SECRET);
        const userid = token_userid.userid;

        const chat = await Chat.findById(roomNo).populate({
            path: 'user',
            select: 'deviceIds',
        }).populate({
            path: 'doctor',
            select: 'name'
        });

        if (chat.doctor._id != userid || chat.isBanned) {
            socket.emit("error: notYourChatorBannedChat");

            return;
        }

        redisClient.subscribe(("CHATROOM_CHANNEL" + roomNo).toString(), (message, channel) => {
            socket.emit('chatReceivedFromServer', message);
        });

        socket.on("SendChat", async (data) => {
            const now = Date.now();
            const chatObject = {role: "doctor", message: data, createdAt: now};

            try {
                await redisClient.lPush(("CHATROOM:QUEUE:" + roomNo).toString(), chatObject);
            } catch (error) {
                console.error(error, "errorAtDoctorSendChat");
            }

            sendDMPushNotification(chat.user.deviceIds, {title: chat.doctor.name + ": 읽지 않은 DM", body: chatObject});

            return;
        });

        socket.on("disconnect", async (reason) => {
            console.log("Doctor socket disconnected");
            try {
                request.get(`http://jeongwoo-kim-web.myds.me:5000/mapp/dm/leaveChat/${roomNo}`, () => {
                    console.log("Successfully disconnected");
                });
            } catch (error) {
                console.error(error, "errorAtDoctorSocketDisconnect");
            }
            return;
        });

    } catch (error) {
        if (error.name === "TokenExpiredError") {
            socket.emit("error", "tokenExpiredError");
        }

        console.error(error, "errorAtChattingDoctor");

        return;
    }
};

module.exports = chatting_doctor;