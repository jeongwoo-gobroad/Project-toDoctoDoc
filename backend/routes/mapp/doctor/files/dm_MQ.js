const { default: mongoose } = require("mongoose");
const redis = require("../../../../config/redis");
const Chat = require("../../../../models/Chat");
const UserSchema = require("../../../../models/User");
const Doctor = require("../../../../models/Doctor");
const User = mongoose.model('User', UserSchema);
const jwt = require("jsonwebtoken");
const { setCacheForThreeDaysAsync, getCache, setCacheForNDaysAsync } = require("../../../../middleware/redisCaching");
const sendDMPushNotification = require("../../push/dmPush");
const { Queue, Worker } = require("bullmq");

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

        const messageQueue = new Queue(roomNo + "_DOCTOR", {
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

        const worker = new Worker(roomNo + "_USER",
            async (job) => {
                console.log("Doctor socket chat received");
                socket.emit("chatReceived", job.data);
                await messageQueue.trimEvents(0);
                await job.remove();
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
            const chatObject = {role: "doctor", message: data, createdAt: now};

            console.log("Doctor socket chat sent");

            messageQueue.add('doctorEmit', chatObject);
            setCacheForNDaysAsync("ROOM:" + roomNo, chatObject, 7);
            // chat.chatList.push(chatObject);
            chat.date = now;
            await chat.save();

            sendDMPushNotification(chat.user.deviceIds, {title: chat.doctor.name + ": 읽지 않은 DM", body: chatObject});

            return;
        });

        socket.on("disconnect", (reason) => {
            console.log("Doctor socket disconnected");
            messageQueue.close();
            worker.close();

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