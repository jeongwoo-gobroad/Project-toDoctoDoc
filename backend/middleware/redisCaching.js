require("dotenv").config;
const redis = require("../config/redis");

const getCache = async (key) => {
    try {
        const cachedData = await redis.redisClient.get(key.toString());

        return cachedData;
    } catch (error) {
        console.error(error);
        return null;
    }
};

const setCache = (key, data) => {
    try {
        // THIS DOES NOT WORK AT ALL!
        // redis.redisClient.set(key, JSON.stringify(data), "EX", process.env.ONE_WEEK_TO_SECONDS);
        redis.redisClient.setEx(key.toString(), process.env.ONE_WEEK_TO_SECONDS, JSON.stringify(data));
    } catch (error) {
        console.error(error);
        return null;
    }
};

const setCacheForThreeDaysAsync = async (key, data) => {
    try {
        // await redis.redisClient.set(key, JSON.stringify(data), "EX", process.env.THREE_DAYS_TO_SECONDS);
        await redis.redisClient.setEx(key.toString(), process.env.THREE_DAYS_TO_SECONDS, JSON.stringify(data));
    } catch (error) {
        console.error(error);
        return null;
    }
};

const delCache = (key) => {
    try {
        redis.redisClient.del(key.toString());
    } catch (error) {
        return null;
    }
};

module.exports = {getCache, setCache, setCacheForThreeDaysAsync, delCache};