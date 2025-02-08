const { parentPort, workerData } = require('worker_threads');
const connectDB = require('../config/db');
const Chat = require('../models/Chat');
const { connectRedis, redisClient } = require('../config/redis');

const { roomNo } = workerData;

connectRedis();
connectDB();

/* 내부적인 메시지 큐로 사용할 배열 */
const queue = [];

const saveChatToDB = async () => {
    try {
        const chat = await Chat.findById(roomNo);

        if (chat) {
            for (const message of queue) {
                chat.chatList.push(message);
            }

            queue = [];
            chat.date = Date.now();
    
            await chat.save();

            return;
        }
    } catch (error) {
        console.error(error, 'errorAtSaveChatToDB');

        return;
    }
};

setInterval(async () => {
    if (queue.length > 0) {
        await saveChatToDB();
    }
}, 500);

parentPort.on('message', async (message) => {
    queue.push(message);
    try {
        if (message.role === 'doctor') {
            await redisClient.publish(roomNo + "/doctor", message);
        } else {
            await redisClient.publish(roomNo + '/user', message);
        }
    } catch (error) {
        console.error(error, 'errorAtParentPortOnMessage');

        return;
    }
});