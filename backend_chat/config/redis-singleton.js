const redis = require('redis');

const redisClient = redis.createClient({
    url: `redis://${process.env.RS_USERNAME}:${process.env.RS_PASSWORD}@${process.env.RS_HOST}:${process.env.RS_PORT}/0`
});

const connectRedis = async () => {
    try {
        const conn = await redisClient.connect();

        if (conn) {
            console.log("Singleton Redis Connected");
        } else {
            console.log("Singleton Redis Connection Error");
        }

        return;
    } catch (error) {
        console.log(error, "errorAtConnectRedis");

        return;
    }
};

const doesKeyExist = async (key) => {
    try {
        return await redisClient.exists(key.toString());
    } catch (error) {
        console.error(error, "errorAtDoesKeyExist");

        return;
    }
};

const doesAtLeastOneUserExist = async (roomNo) => {
    try {
        const users = await redisClient.hGetAll(("CHAT:MEMBER:" + roomNo).toString());

        if (parseInt(users.DOCTOR) == 0 && parseInt(users.USER) == 0) {
            return false;
        }

        return true;
    } catch (error) {
        console.error(error, "errorAtDoesAtLeastOneUserExist");

        return;
    }
};

const popMessageFromMessageQueue = async (channel) => {
    try {
        const rtn = await redisClient.rPop(channel.toString());

        return rtn;
    } catch (error) {
        console.error(error, "errorAtPopMessageFromMessageQueue");

        return;
    }
};

const atomicallyIncrement = async (key) => {
    try {
        return await redisClient.incr(key.toString());
    } catch (error) {
        console.error(error, "errorAtAtomicallyIncrement");

        return;
    }
};

const setCacheForever = async (key, data) => {
    try {
        await redisClient.set(key.toString(), JSON.stringify(data));
        
        return;
    } catch (error) {
        console.error(error, "errorAtSetCacheForever");

        return null;
    }
}

const publishMessageToChatId = async (chatId, message) => {
    try {
        await redisClient.publish(("CHATROOM_CHANNEL:" + chatId).toString(), JSON.stringify(message));
    } catch (error) {
        console.error(error, "errorAtPublishMessageToChatId");

        return;
    }
};

const publishMessageToUserId = async (userId, message) => {
    try {
        await redisClient.publish(("CHATROOM_USER_CHANNEL:" + userId).toString(), JSON.stringify(message));
    } catch (error) {
        console.error(error, "errorAtPublishMessageToUserId");

        return;
    }
};

const publishMessageToDoctorId = async (doctorId, message) => {
    try {
        await redisClient.publish(("CHATROOM_DOCTOR_CHANNEL:" + doctorId).toString(), JSON.stringify(message));
    } catch (error) {
        console.error(error, "errorAtPublishMessageToDoctorId");

        return;
    }
};

module.exports = {
    redisClient, connectRedis, doesKeyExist, popMessageFromMessageQueue, 
    atomicallyIncrement, setCacheForever, publishMessageToChatId, doesAtLeastOneUserExist, 
    publishMessageToUserId, publishMessageToDoctorId,
};