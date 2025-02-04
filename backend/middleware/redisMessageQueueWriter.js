const {parentPort} = require('worker_threads');
const { pushMessage } = require('./redisMessageQueueing');
const { connectRedis } = require('../config/redis');

connectRedis();

parentPort.on('message', async (data) => {
    const key = data.key;
    const message = data.message;

    // console.log(key, message);

    await pushMessage(key, message);
});