const jwt = require("jsonwebtoken");
const { Worker } = require('worker_threads');
const Chat = require("../../../models/Chat");
const sendDMPushNotification = require("../push/dmPush");
const { setCacheForNDaysAsync } = require("../../../middleware/redisCaching");

const chatting_user = async (socket, next) => {
    const token = socket.handshake.query.token;
    const roomNo = socket.handshake.query.roomNo;

    console.log("User socket connected");

    try {
        const token_userid = jwt.verify(token, process.env.JWT_SECRET);
        const userid = token_userid.userid;

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

        // const messageQueue = new Queue(roomNo + "_USER", {
        //     connection: {
        //         host: process.env.RS_HOST,
        //         port: process.env.RS_PORT,
        //         username: process.env.RS_USERNAME,
        //         password: process.env.RS_NONESCAPE_PASSWORD,
        //     },
        //     defaultJobOptions: {
        //         removeOnComplete: true,
        //         removeOnFail: true,
        //     }
        // });

        // const doctorMessageQueue = new Queue(roomNo + "_DOCTOR", {
        //     connection: {
        //         host: process.env.RS_HOST,
        //         port: process.env.RS_PORT,
        //         username: process.env.RS_USERNAME,
        //         password: process.env.RS_NONESCAPE_PASSWORD,
        //     },
        //     defaultJobOptions: {
        //         removeOnComplete: true,
        //         removeOnFail: true,
        //     }
        // });

        // const worker = new Worker(roomNo + "_DOCTOR",
        //     async (job) => {
        //         // console.log("User socket chat received");
        //         socket.emit("chatReceived", job.data);
        //         try {
        //             await doctorMessageQueue.trimEvents(0);
        //         } catch (error) {
        //             console.error(error, "errorAtUserSocketChatReceived");
        //         }

        //         return null;
        //     }, {
        //         connection: {
        //             host: process.env.RS_HOST,
        //             port: process.env.RS_PORT,
        //             username: process.env.RS_USERNAME,
        //             password: process.env.RS_NONESCAPE_PASSWORD,
        //         },
        //         removeOnComplete: {count: 0},
        //         removeOnFail: {count: 0}
        //     }
        // );
        const receiver = new Worker('./middleware/redisMessageQueueReader');
        const sender   = new Worker('./middleware/redisMessageQueueWriter');

        receiver.postMessage({key: roomNo, role: 'user'});

        receiver.on('message', (data) => {
            socket.emit("chatReceived", data);
        });

        socket.on("SendChat", async (data) => {
            const now = Date.now();
            const chatObject = {role: "user", message: data, createdAt: now};

            // console.log("User socket chat sent");

            try {
                // await messageQueue.add('userEmit', chatObject);
                sender.postMessage({key: roomNo, message: chatObject});
                setCacheForNDaysAsync("ROOM:" + roomNo, chatObject, 7);
                // chat.chatList.push(chatObject);
                chat.date = now;
                await chat.save();
            } catch (error) {
                console.error(error, "errorAtUserSendChat");
            }

            sendDMPushNotification(chat.doctor.deviceIds, {title: chat.user.usernick + ": 읽지 않은 DM", body: chatObject});

            return;
        });

        socket.on("disconnect", async (reason) => {
            console.log("User socket disconnected");
            try {
                // await messageQueue.close();
                // await doctorMessageQueue.close();
                // await worker.close();
                receiver.terminate();
                sender.terminate();
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