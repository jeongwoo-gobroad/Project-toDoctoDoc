const { default: mongoose } = require("mongoose");
const Chat = require("../../../../models/Chat");
const UserSchema = require("../../../../models/User");
const axios = require('axios');
const jwt = require("jsonwebtoken");
const sendDMPushNotification = require("../../push/dmPush");
const Redis = require("../../../../config/redisObject");

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

        let receiver = new Redis();

        await receiver.connect();

        let sender = new Redis();

        await sender.connect();

        sender.incrementHashValue("CHAT:MEMBER:" + roomNo, "DOCTOR");

        receiver.redisClient.subscribe(("CHATROOM_CHANNEL:" + roomNo).toString(), (message, channel) => {
            socket.emit('chatReceivedFromServer', message);
        });

        socket.on("SendChat", async (data) => {
            const now = Date.now();
            const chatObject = {role: "doctor", message: data, createdAt: now};

            try {
                await sender.pushMessageToMessageQueue("CHATROOM:QUEUE:" + roomNo, chatObject);
            } catch (error) {
                console.error(error, "errorAtDoctorSendChat");
            }

            if (!(await sender.getHashValue("CHAT:MEMBER:" + roomNo, "USER"))) {
                sendDMPushNotification(chat.user.deviceIds, {title: chat.doctor.name + ": 읽지 않은 DM", body: chatObject});
            }

            return;
        }); 

        socket.on("disconnect", async (reason) => {
            console.log("Doctor socket disconnected");
            try {
                await receiver.redisClient.unsubscribe(("CHATROOM_CHANNEL:" + roomNo).toString());
                receiver.closeConnnection();
                receiver = null;

                sender.decrementHashValue("CHAT:MEMBER:" + roomNo, "DOCTOR");
                sender.closeConnnection();
                sender = null;

                const uri = encodeURI(`http://jeongwoo-kim-web.myds.me:5000/mapp/dm/leaveChat/${roomNo}`);
                const uriOptions = {
                    method: 'GET',
                    data: {},
                    headers: {
                        authorization: 'Bearer: ' + token
                    }
                };
                await axios.get(uri, uriOptions);

                console.log("successfully disconnected");
            } catch (error) {
                console.error(error, "errorAtDoctorSocketDisconnect");
            }
            return;
        });

        socket.on("error", async (error) => {
            console.log("Doctor socket error", error);

            try {
                await receiver.redisClient.unsubscribe(("CHATROOM_CHANNEL:" + roomNo).toString());
                receiver.closeConnnection();
                receiver = null;
                
                sender.decrementHashValue("CHAT:MEMBER:" + roomNo, "DOCTOR");
                sender.closeConnnection();
                sender = null;

                const uri = encodeURI(`http://jeongwoo-kim-web.myds.me:5000/mapp/dm/leaveChat/${roomNo}`);
                const uriOptions = {
                    method: 'GET',
                    data: {},
                    headers: {
                        authorization: 'Bearer: ' + token
                    }
                };
                await axios.get(uri, uriOptions);

                console.log("successfully disconnected");
            } catch (error) {
                console.error(error, "errorAtUserSocketDisconnect");
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