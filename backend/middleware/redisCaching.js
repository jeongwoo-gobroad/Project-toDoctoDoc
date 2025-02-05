require("dotenv").config;
const redis = require("../config/redis");

const getHashValue = async (key, field) => {
    try {
        const value = await redis.redisClient.hGet(key.toString(), field.toString());

        return JSON.parse(value);
    } catch (error) {
        console.error(error);
        return null;
    }
};

const setHashValue = async (key, field, value) => {
    try {
        await redis.redisClient.hSet(key.toString(), field.toString(), JSON.stringify(value));
    } catch (error) {
        console.error(error);
        return null;
    }
};

const getHashAll = async (key) => {
    try {
        const value = await redis.redisClient.hGetAll(key.toString());

        const map = new Map(Object.entries(value));

        for (const [key, val] of map) {
            map.set(key, JSON.parse(val));
        }

        return map;
    } catch (error) {
        console.error(error);
        return null;
    }
};

const getCache = async (key) => {
    try {
        const cachedData = await redis.redisClient.get(key.toString());

        return JSON.parse(cachedData);
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

const setCacheForNDaysAsync = async (key, data, days) => {
    try {
        await redis.redisClient.setEx(key.toString(), process.env.ONE_DAY_TO_SECONDS * parseInt(days), JSON.stringify(data));
    } catch (error) {
        console.error(error, "errorAtSetCacheForNDaysAsync");

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

module.exports = {getHashAll, getHashValue, setHashValue, getCache, setCache, setCacheForThreeDaysAsync, setCacheForNDaysAsync, delCache};