require('dotenv').config({path: "../_secrets/dotenv/.env"});
const { parentPort, workerData } = require('worker_threads');
const { connectRedis, redisClient } = require('../config/redis');
const connectDB = require('../config/mongo');
const { publishMessageToChatId } = require('./functions/redisOperations');
const Chat = require('../models/Chat');

const { chatId } = workerData;

connectRedis();
connectDB();

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

        parentPort.postMessage(wholeChatBubble);

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
        if (await redisClient.exists(("CHATROOM:QUEUE:" + chatId).toString())) {
            const message = await redisClient.rPop(("CHATROOM:QUEUE:" + chatId).toString());
            if (message) {
                const messageCount = await redisClient.incr(("CHATROOM:CNTER:" + chatId).toString());
            

                // console.log("Message Popped from Queue: ", message);

                const newMessage = JSON.parse(message);

                newMessage.autoIncrementId = messageCount;

                globalSubQueue.push(newMessage);
                await redisClient.set(("CHATROOM:RECENT:" + chatId).toString(), JSON.stringify(newMessage));
                publishMessageToChatId(chatId, newMessage);
            }
        }
    } catch (error) {
        console.error(error, "errorAtPopFromSharedMessageQueueAndIncrementCid");

        return;
    }
}, 0);