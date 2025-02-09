const jwt = require("jsonwebtoken");
const Chat = require("../../../models/Chat");
const axios = require('axios');
const sendDMPushNotification = require("../push/dmPush");
const { setCacheForNDaysAsync, removeItemFromSet, doesSetContains, setSetForever } = require("../../../middleware/redisCaching");
const { redisClient } = require("../../../config/redis");
const Redis = require("../../../config/redisObject");

const chatting_user = async (socket, next) => {
    const token = socket.handshake.query.token;
    const roomNo = socket.handshake.query.roomNo;

    console.log("User socket connected");

    try {
        const token_userid = jwt.verify(token, process.env.JWT_SECRET);
        const userid = token_userid.userid;

        setSetForever("CHAT:MEMBER:" + roomNo, "USER");

        const chat = await Chat.findById(roomNo).populate({
            path: 'doctor',
            select: 'deviceIds'
        }).populate({
            path: 'user',
            select: 'usernick'
        });

        if (chat.user._id != userid || chat.isBanned) {
            socket.emit("error: notYourChatorBannedChat");

            return;
        }

        const receiver = new Redis();

        receiver.redisClient.subscribe(("CHATROOM_CHANNEL" + roomNo).toString(), (message, channel) => {
            socket.emit('chatReceivedFromServer', message);
        });

        socket.on("SendChat", async (data) => {
            const now = Date.now();
            const chatObject = {role: "user", message: data, createdAt: now};

            try {
                await redisClient.lPush(("CHATROOM:QUEUE:" + roomNo).toString(), JSON.stringify(chatObject));
            } catch (error) {   
                console.error(error, "errorAtUserSendChat");
            }

            if (!(await doesSetContains("CHAT:MEMBER:" + roomNo, "DOCTOR"))) {
                sendDMPushNotification(chat.doctor.deviceIds, {title: chat.user.usernick + ": 읽지 않은 DM", body: chatObject});
            }

            return;
        });

        socket.on("disconnect", async (reason) => {
            console.log("User socket disconnected");
            try {
                receiver.closeConnnection();
                await redisClient.unsubscribe(("CHATROOM_CHANNEL" + roomNo).toString());
                removeItemFromSet("CHAT:MEMBER:" + roomNo, "USER");

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

        console.error(error, "errorAtChattingUser");

        return;
    }
};

module.exports = chatting_user;