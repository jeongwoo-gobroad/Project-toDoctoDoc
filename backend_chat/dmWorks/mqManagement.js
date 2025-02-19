require('dotenv').config({path: "../_secrets/dotenv/.env"});
const { parentPort, workerData } = require('worker_threads');
const connectDB = require('../config/mongo');
const Chat = require('../models/Chat');
const { connectRedis, doesKeyExist, popMessageFromMessageQueue, atomicallyIncrement, setCacheForever, publishMessageToChatId, publishMessageToUserId, publishMessageToDoctorId } = require('../config/redis-singleton');

const { chatId, userId, doctorId } = workerData;

connectDB();
connectRedis();

let globalSubQueue = [];

const getSpecificIndex = (array, targetValue) => {
    return new Promise((resolve, reject) => {
        try {
            let index = 0;
            array.forEach((element) => {
                // console.log(element.autoIncrementId, targetValue);
                if (parseInt(element.autoIncrementId) === parseInt(targetValue)) {
                    resolve(index);
                }
                index++;
            });
            resolve(index);
        } catch (error) {
            reject(error);
        }
    });
}

parentPort.on('message', async (currentCnter) => {
    try {
        const chatSchema = await Chat.findById(chatId);

        const chats = chatSchema.chatList.slice(await getSpecificIndex(chatSchema.chatList, currentCnter) + 1);

        // console.log("Chats: ", chats);

        const wholeChatBubble = chats.concat(globalSubQueue);

        parentPort.postMessage(JSON.stringify(wholeChatBubble));

        // console.log(wholeChatBubble, "sent to parentPort");

        return;
    } catch (error) {
        parentPort.postMessage("");

        console.error(error, "errorAtReadNewMessageAfterGivenCnter");

        return;
    }
});

setInterval(async () => {
    if (globalSubQueue.length > 0) {
        try {
            await Chat.findByIdAndUpdate(chatId, {
                date: Date.now(),
                $push: {
                    chatList: {
                        $each: globalSubQueue
                    }
                }
            });

            // console.log(globalSubQueue, "inserted to DB");

            globalSubQueue = [];
        } catch (error) {
            console.error(error, "errorAtSetInterval");

            return;
        }
    }
}, 5000);

setInterval(async () => {
    try {
        if (await doesKeyExist("CHATROOM:QUEUE:" + chatId)) {
            const message = await popMessageFromMessageQueue("CHATROOM:QUEUE:" + chatId);
            if (message) {
                const messageCount = await atomicallyIncrement("CHATROOM:CNTER:" + chatId);
            

                // console.log("Message Popped from Queue: ", message);

                const newMessage = JSON.parse(message);

                newMessage.autoIncrementId = messageCount;

                globalSubQueue.push(newMessage);
                await setCacheForever("CHATROOM:RECENT:" + chatId, newMessage);
                await publishMessageToChatId(chatId, newMessage);
                await publishMessageToUserId(userId, "newMessage");
                await publishMessageToDoctorId(doctorId, "newMessage");
            }
        }
    } catch (error) {
        console.error(error, "errorAtPopFromSharedMessageQueueAndIncrementCid");

        return;
    }
}, 1);