const jwt = require("jsonwebtoken");
const { Queue, Worker } = require("bullmq");
const Chat = require("../../../models/Chat");
const sendDMPushNotification = require("../push/dmPush");
const { setCacheForNDaysAsync } = require("../../../middleware/redisCaching");

const chatting_user = async (socket, next) => {
    const token = socket.handshake.query.token;
    const roomNo = socket.handshake.query.roomNo;

    try {
        const token_userid = jwt.verify(token, process.env.JWT_SECRET);
        const userid = token_userid.userid;

        const chat = await Chat.findById(roomNo).populate('doctor', 'deviceIds');

        if (chat.doctor != userid || chat.isBanned) {
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
                socket.emit("chatReceived", job.data);
                job.remove();
            }, {
                connection: {
                    host: process.env.RS_HOST,
                    port: process.env.RS_PORT,
                    username: process.env.RS_USERNAME,
                    password: process.env.RS_NONESCAPE_PASSWORD,
                }
            }
        );

        socket.on("SendChat", async (data) => {
            const now = Date.now();
            const chatObject = {role: "user", message: data, createdAt: now};

            messageQueue.add('userEmit', chatObject);
            setCacheForNDaysAsync("ROOM_" + roomNo, chatObject, 7);
            // chat.chatList.push(chatObject);
            chat.date = now;
            await chat.save();

            sendDMPushNotification(chat.user.deviceIds, chatObject);

            return;
        });

        socket.on("disconnect", (reason) => {
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