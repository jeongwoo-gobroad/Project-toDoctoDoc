const { default: mongoose } = require("mongoose");
const redis = require("../../../config/redis");
const Chat = require("../../../models/Chat");
const UserSchema = require("../../../models/User");
const Doctor = require("../../../models/Doctor");
const User = mongoose.model('User', UserSchema);

const chatting_user = async (socket, next) => {
    const token = socket.handshake.query.token;

    const token_userid = jwt.verify(token, process.env.JWT_SECRET);

    const userid = token_userid.userid;

    try {
        const state = User.findById(userid);

        if (!state) {
            socket.emit("error", "noSuchDocID");

            return;
        }
    
        socket.on('joinChat_user', async (data) => {
            try {
                const roomNo = data;
    
                const chat = await Chat.findById(roomNo);
    
                if (chat.user != userid) {  
                    socket.emit("error", "notYourChat");
    
                    return;
                }
    
                socket.join(roomNo);
                const peopleCount = await redis.redisClient.get("room: " + roomNo);
                peopleCount++;
                await redis.redisClient.set("room: " + roomNo, peopleCount);
    
                const unreadChats = JSON.parse(await redis.redisClient.get(userid));
                delete unreadChats.roomNo;
                await redis.redisClient.set(userid, unreadChats);
    
                socket.emit("returnJoinedChat", chat);
            } catch (error) {
                socket.emit("error", "errorAtJoinChat");
    
                console.log(error, "errorAtJoinChat");
            }
        });
    
        socket.on('leaveChat_user', async (data) => {
            try {
                const roomNo = data;
    
                const chat = await Chat.findById(roomNo);
    
                if (chat.user != userid) {  
                    socket.emit("error", "notYourChat");
    
                    return;
                }
    
                socket.leave(roomNo);
                const peopleCount = await redis.redisClient.get("room: " + roomNo);
                peopleCount--;
                await redis.redisClient.set("room: " + roomNo, peopleCount);
    
                const unreadChats = JSON.parse(await redis.redisClient.get(userid));
    
                unreadChats.roomNo = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: 0};
    
                await redis.redisClient.set(userid, unreadChats);
    
                socket.emit("returnLeftChat", "-");
            } catch (error) {
                socket.emit("error", "errorAtLeaveChat");
    
                console.log(error, "errorAtLeaveChat");
            }
        });
    
        socket.on('sendChat_user', async (data) => {
            try {
                const struct = JSON.parse(data);
    
                const chat = await Chat.findById(struct.roomNo);
    
                if (chat.user != userid) {  
                    socket.emit("error", "notYourChat");
    
                    return;
                }
    
                
    
                chat.chatList.push({role: "user", message: struct.message});
                await chat.save();
    
                if (await redis.redisClient.get("room: " + struct.roomNo) == 1) {
                    const unreadChats = JSON.parse(await redis.redisClient.get(chat.doctor));
    
                    unreadChats.roomNo = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: unreadChats.roomNo.unread + 1};

                    socket.emit("unread_doctor", "-");
                } else {
                    socket.to(struct.roomNo).emit("recvChat_doctor", {role: "user", message: struct.message});
                }
    
                return;
            } catch (error) {
                socket.emit("error", "errorAtSendChat");
    
                console.log(error, "errorAtSendChat");
            }
        });

    } catch (error) {
        socket.emit("error", "errorAtInitializing");
        
        console.error(error);

        return;
    }
};

module.exports = chatting_user;