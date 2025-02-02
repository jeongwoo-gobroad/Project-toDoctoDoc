const jwt = require("jsonwebtoken");
const { Queue, Worker } = require("bullmq");
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

        const messageQueue = new Queue(roomNo + "_USER", {
            connection: {
                host: process.env.RS_HOST,
                port: process.env.RS_PORT,
                username: process.env.RS_USERNAME,
                password: process.env.RS_NONESCAPE_PASSWORD,
            },
            defaultJobOptions: {
                removeOnComplete: true,
                removeOnFail: true,
            }
        });

        const worker = new Worker(roomNo + "_DOCTOR",
            async (job) => {
                console.log("User socket chat received");
                socket.emit("chatReceived", job.data);
                await job.remove();
                await messageQueue.trimEvents(0);
            }, {
                connection: {
                    host: process.env.RS_HOST,
                    port: process.env.RS_PORT,
                    username: process.env.RS_USERNAME,
                    password: process.env.RS_NONESCAPE_PASSWORD,
                },
                removeOnComplete: {count: 0},
                removeOnFail: {count: 0}
            }
        );

        socket.on("SendChat", async (data) => {
            const now = Date.now();
            const chatObject = {role: "user", message: data, createdAt: now};

            console.log("User socket chat sent");

            messageQueue.add('userEmit', chatObject);
            setCacheForNDaysAsync("ROOM:" + roomNo, chatObject, 7);
            // chat.chatList.push(chatObject);
            chat.date = now;
            await chat.save();

            sendDMPushNotification(chat.doctor.deviceIds, {title: chat.user.usernick + ": 읽지 않은 DM", body: chatObject});

            return;
        });

        socket.on("disconnect", (reason) => {
            console.log("User socket disconnected");
            messageQueue.close();
            worker.close();

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