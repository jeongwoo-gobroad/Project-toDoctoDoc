const { default: mongoose } = require("mongoose");
const redis = require("../../../config/redis");
const Chat = require("../../../models/Chat");
const UserSchema = require("../../../models/User");
const Doctor = require("../../../models/Doctor");
const User = mongoose.model('User', UserSchema);
const jwt = require("jsonwebtoken");
const { getCache } = require("../../../middleware/redisCaching");

const chatting_main = async (socket, next) => {
    const token = socket.handshake.query.token;

    try {
        const token_userid = jwt.verify(token, process.env.JWT_SECRET);
    
        const userid = token_userid.userid;
    
        socket.on('chatList', async (data) => {
            try {
                // console.log("chatList");
    
                const unreadChats = JSON.parse(await getCache(userid));
    
                socket.emit('returnChatList', unreadChats);
            } catch (error) {
                socket.emit("error", "errorAtChatList");
    
                console.log(error, "errorAtChatList");
            }
        });
    } catch (error) {
        if (error.name === "TokenExpiredError") {
            socket.emit("error", "tokenExpiredError");
        }

        return;
    }
};

module.exports = chatting_main;