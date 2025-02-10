const redis = require("redis");

const redisClient = redis.createClient({
    url: `redis://${process.env.RS_USERNAME}:${process.env.RS_PASSWORD}@${process.env.RS_HOST}:${process.env.RS_PORT}/0`
});

const connectRedis = async () => {
    const conn = await redisClient.connect();

    if (conn) {
        console.log("Redis connected from chat server");
    } else {
        console.log("Redis connection error from chat server");
    }
    
    return;
}

const disconnectRedis = async () => {
    try {
        await redisClient.disconnect();

        console.log("Redis disconnected");

        return;
    } catch (error) {
        console.error(error, "errorAtConnectRedis");

        return;
    }
};

module.exports = {connectRedis, disconnectRedis, redisClient};