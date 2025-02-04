const redis = require("../config/redis");

const pushMessage = async (key, message) => {
    await redis.redisClient.lPush(("MESSAGE:" + key).toString(), JSON.stringify(message));
    await redis.redisClient.expire(("MESSAGE:" + key).toString(), process.env.THREE_DAYS_TO_SECONDS);

    return;
};

const messageCount = async (key) => {
    return await redis.redisClient.lLen(("MESSAGE:" + key).toString());
};

const popMessage = async (key) => {
    return JSON.parse((await redis.redisClient.rPop(("MESSAGE:" + key).toString())));
}

const peekMessage = async (key) => {
    let rtnVal = null;

    if ((rtnVal = await messageCount(key))) {
        return JSON.parse((await redis.redisClient.lIndex(("MESSAGE:" + key).toString(), rtnVal - 1)));
    }

    return null;
}

module.exports = {pushMessage, messageCount, popMessage, peekMessage};