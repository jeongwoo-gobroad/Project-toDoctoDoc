const redis = require("../config/redis");

const setSetForNDays = async (key, item, days) => {
    try {
        await redis.redisClient.sAdd(key.toString(), JSON.stringify(item));
        await redis.redisClient.expire(key.toString(), process.env.ONE_DAY_TO_SECONDS * parseInt(days));

        return;
    } catch (error) {
        console.error(error);
        return null;
    }
};

const setSetForever = async (key, item) => {
    try {
        await redis.redisClient.sAdd(key.toString(), JSON.stringify(item));

        return;
    } catch (error) {
        console.error(error);
        return null;
    }
};

const removeItemFromSet = async (key, item) => {
    try {
        await redis.redisClient.sRem(key.toString(), JSON.stringify(item));

        return;
    } catch (error) {
        console.error(error);
        return null;
    }
};

const doesSetContains = async (key, item) => {
    try {
        return (await redis.redisClient.sIsMember(key.toString(), JSON.stringify(item)));
    } catch (error) {
        console.error(error);
        return null;
    }
};

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

const setHashValueWithTTL = async (key, field, value, days) => {
    try {
        await redis.redisClient.hSet(key.toString(), field.toString(), JSON.stringify(value));
        await redis.redisClient.hExpire(key.toString(), field.toString(), process.env.ONE_DAY_TO_SECONDS * parseInt(days));
        await redis.redisClient.expire(key.toString(), process.env.ONE_DAY_TO_SECONDS * parseInt(days));
    } catch (error) {
        console.error(error, "errorAtSetHashValueWithTTL");

        return null;
    }
};

const doesHashContains = async (key, field) => {
    try {
        return (await redis.redisClient.hExists(key.toString(), field.toString()));
    } catch (error) {
        console.error(error, "errorAtDoesHashContains");
        return null;
    }
}

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

const setCache = async (key, data) => {
    try {
        // THIS DOES NOT WORK AT ALL!
        // redis.redisClient.set(key, JSON.stringify(data), "EX", process.env.ONE_WEEK_TO_SECONDS);
        await redis.redisClient.setEx(key.toString(), process.env.ONE_WEEK_TO_SECONDS, JSON.stringify(data));
    } catch (error) {
        console.error(error);
        return null;
    }
};

const setCacheForever = async (key, data) => {
    try {
        await redis.redisClient.set(key.toString(), JSON.stringify(data));
    } catch (error) {
        console.error(error, "errorAtSetCacheForever");

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

const delCache = async (key) => {
    try {
        await redis.redisClient.del(key.toString());
    } catch (error) {
        return null;
    }
};

module.exports = {
    getHashAll, getHashValue, setHashValue, getCache, setCache, setCacheForever,
    setCacheForThreeDaysAsync, setCacheForNDaysAsync, delCache,
    setSetForNDays, setSetForever, doesSetContains, removeItemFromSet, setHashValueWithTTL, doesHashContains,
};