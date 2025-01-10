require("dotenv").config;
const redis = require("../config/redis");

const getCache = async (key) => {
    try {
        const cachedData = await redis.redisClient.get(key);

        return cachedData;
    } catch (error) {
        return null;
    }
};

const setCache = (key, data) => {
    try {
        redis.redisClient.set(key, JSON.stringify(data), "EX", process.env.ONE_WEEK_TO_SECONDS);
    } catch (error) {
        return null;
    }
};

const delCache = (key) => {
    try {
        redis.redisClient.del(key);
    } catch (error) {
        return null;
    }
};

module.exports = {getCache, setCache, delCache};