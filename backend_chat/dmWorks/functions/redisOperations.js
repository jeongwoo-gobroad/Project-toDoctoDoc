const { redisClient } = require("../../config/redis");

const publishMessageToChatId = async (chatId, message) => {
    try {
        await redisClient.publish(("CHATROOM_CHANNEL:" + chatId).toString(), JSON.stringify(message));
    } catch (error) {
        console.error(error, "errorAtPublishMessageToChatId");

        return;
    }
};

module.exports = {publishMessageToChatId};