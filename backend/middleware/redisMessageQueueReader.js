const {parentPort} = require('worker_threads');
const { peekMessage, popMessage } = require('./redisMessageQueueing');
const { connectRedis } = require('../config/redis');

parentPort.on('message', async (data) => {
    const key = data.key;
    const role = data.role;

    await connectRedis();

    while (true) {
        const peek = await peekMessage(key);
        if (peek && peek.role !== role) {
            // console.log(peek.role, "/", role);
            // console.log(role, ":", peek);
            parentPort.postMessage(await popMessage(key));
        }
    }
});