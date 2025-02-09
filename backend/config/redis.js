require("dotenv").config({path: "../secrets/dotenv/.env"});
const redis = require("redis");

const redisClient = redis.createClient({
    url: `redis://${process.env.RS_USERNAME}:${process.env.RS_PASSWORD}@${process.env.RS_HOST}:${process.env.RS_PORT}/0`
});

const connectRedis = async () => {
    try {
        const conn = await redisClient.connect();

        if (conn) {
            console.log("Redis connected");
        }

        return;
    } catch (error) {
        console.error(error, "errorAtConnectRedis");

        return;
    }
};

const disconnectRedis = async () => {
    try {
        const conn = await redisClient.disconnect();

        if (conn) {
            console.log("Redis connected");
        }

        return;
    } catch (error) {
        console.error(error, "errorAtConnectRedis");

        return;
    }
};

module.exports = {connectRedis, disconnectRedis, redisClient};