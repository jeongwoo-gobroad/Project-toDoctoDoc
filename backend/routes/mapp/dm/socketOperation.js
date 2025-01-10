const { default: mongoose } = require("mongoose");
const redis = require("../../../config/redis");
const Chat = require("../../../models/Chat");
const UserSchema = require("../../../models/User");
const Doctor = require("../../../models/Doctor");
const User = mongoose.model('User', UserSchema);

const chatting_main = async (socket, next) => {
    const token = socket.handshake.query.token;

    const token_userid = jwt.verify(token, process.env.JWT_SECRET);

    const userid = token_userid.userid;

    socket.on('chatList', async (data) => {
        try {
            const unreadChats = JSON.parse(await redis.redisClient.get(userid));

            socket.emit('returnChatList', unreadChats);
        } catch (error) {
            socket.emit("error", "errorAtChatList");

            console.log(error, "errorAtChatList");
        }
    });
};

module.exports = chatting_main;