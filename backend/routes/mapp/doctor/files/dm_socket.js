const { default: mongoose } = require("mongoose");
const redis = require("../../../../config/redis");
const Chat = require("../../../../models/Chat");
const UserSchema = require("../../../../models/User");
const Doctor = require("../../../../models/Doctor");
const User = mongoose.model('User', UserSchema);
const jwt = require("jsonwebtoken");
const { setCacheForThreeDaysAsync } = require("../../../../middleware/redisCaching");

const chatting_doctor = async (socket, next) => {
    const token = socket.handshake.query.token;

    try {
        const token_userid = jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
        if (error.name === "TokenExpiredError") {
            socket.emit("error", "tokenExpiredError");
        }

        return;
    }
    const userid = token_userid.userid;

    try {
        const state = Doctor.findById(userid);

        if (!state) {
            socket.emit("error", "noSuchDocID");

            return;
        }
    
        socket.on('joinChat_doctor', async (data) => {
            try {
                const roomNo = data;
    
                const chat = await Chat.findById(roomNo);
    
                if (chat.doctor != userid) {  
                    socket.emit("error", "notYourChat");
    
                    return;
                }
    
                socket.join(roomNo);
                let peopleCount = await redis.redisClient.get("room: " + roomNo);
                peopleCount++;
                // await redis.redisClient.set("room: " + roomNo, peopleCount);
                await setCacheForThreeDaysAsync("room: " + roomNo, peopleCount);
    
                const unreadChats = JSON.parse(await redis.redisClient.get(userid));
                if (unreadChats && unreadChats.roomNo) {
                    delete unreadChats.roomNo;
                    // await redis.redisClient.set(userid, unreadChats);
                    await setCacheForThreeDaysAsync(userid, unreadChats);
                }
    
                socket.emit("returnJoinedChat", chat);
            } catch (error) {
                socket.emit("error", "errorAtJoinChat");
    
                console.log(error, "errorAtJoinChat");
            }
        });
    
        socket.on('leaveChat_doctor', async (data) => {
            try {
                const roomNo = data;
    
                const chat = await Chat.findById(roomNo);
    
                if (chat.doctor != userid) {  
                    socket.emit("error", "notYourChat");
    
                    return;
                }
    
                socket.leave(roomNo);
                let peopleCount = await redis.redisClient.get("room: " + roomNo);
                peopleCount--;
                await setCacheForThreeDaysAsync("room: " + roomNo, peopleCount);
    
                const unreadChats = JSON.parse(await redis.redisClient.get(userid));
    
                unreadChats.roomNo = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: 0};
    
                await setCacheForThreeDaysAsync(userid, unreadChats);
    
                socket.emit("returnLeftChat", "-");
            } catch (error) {
                socket.emit("error", "errorAtLeaveChat");
    
                console.log(error, "errorAtLeaveChat");
            }
        });
    
        socket.on('sendChat_doctor', async (data) => {
            try {
                const struct = JSON.parse(data);
    
                const chat = await Chat.findById(struct.roomNo);
    
                if (chat.doctor != userid) {  
                    socket.emit("error", "notYourChat");
    
                    return;
                }         
    
                chat.chatList.push({role: "doctor", message: struct.message});
                chat.chatList.data = Date.now();
                await chat.save();
    
                if (await redis.redisClient.get("room: " + struct.roomNo) == 1) {
                    const unreadChats = JSON.parse(await redis.redisClient.get(chat.user));
    
                    unreadChats.roomNo = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: unreadChats.roomNo.unread + 1};

                    socket.emit("unread_user", "-");
                } else {
                    socket.to(struct.roomNo).emit("recvChat_user", {role: "doctor", message: struct.message});
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

module.exports = chatting_doctor;