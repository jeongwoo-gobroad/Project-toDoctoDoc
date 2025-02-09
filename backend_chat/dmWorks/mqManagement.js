require('dotenv').config({path: "../_secrets/dotenv/.env"});
const { parentPort, workerData } = require('worker_threads');
const { connectRedis, redisClient } = require('../config/redis');
const connectDB = require('../config/mongo');
const { publishMessageToChatId } = require('./functions/redisOperations');
const Chat = require('../models/Chat');

const { chatId } = workerData;

connectRedis();
connectDB();

const globalSubQueue = [];

parentPort.on('message', async (currentCnter) => {
    try {
        const chatSchema = await Chat.aggregate([
            {
                $match: {_id: chatId}
            },
            {
                $project:{
                    chatList: {
                        $let: {
                            vars: {
                                startIndex: {
                                    $indexOfArray: [
                                        "$chatList.autoIncrementId",
                                        currentCnter
                                    ]
                                }
                            },
                            in: {
                                $cond: [
                                    {$gt: ["$$startIndex", 0]},
                                    {$slice: ["$chatList", "$$startIndex"]},
                                    []
                                ]
                            }
                        }
                    }
                }
            }
        ]);

        const chats = chatSchema.chatList;

        const wholeChatBubble = chats.concat(globalSubQueue);

        parentPort.postMessage(wholeChatBubble);

        console.log(wholeChatBubble, "sent to parentPort");

        return;
    } catch (error) {
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

            console.log(globalSubQueue, "inserted to DB");

            globalSubQueue = [];
        } catch (error) {
            console.error("errorAtSetInterval");

            return;
        }
    }
}, 5000);

setInterval(async () => {
    try {
        if (await redisClient.exists(("CHATROOM:QUEUE:" + chatId).toString())) {
            const messageCount = await redisClient.incr(("CHATROOM:CNTER:" + chatId).toString());
            const message = await redisClient.rPop(("CHATROOM:QUEUE:" + chatId).toString());

            console.log("Message Popped from Queue: ", message);

            const newMessage = JSON.parse(message);

            newMessage.autoIncrementId = messageCount;

            globalSubQueue.push(newMessage);
            await redisClient.set(("CHATROOM:RECENT:" + chatId).toString(), newMessage);
            publishMessageToChatId(chatId, newMessage);
        }
    } catch (error) {
        console.error(error, "errorAtPopFromSharedMessageQueueAndIncrementCid");

        return;
    }
}, 0);