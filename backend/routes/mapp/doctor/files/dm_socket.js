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
        
                    socket.leave(roomNo);
        
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

                    // console.log(data);

                    const now = Date.now();
        
                    if (chat.doctor != userid) {  
                        socket.emit("error", "notYourChat");
        
                        return;
                    }         
        
                    chat.chatList.push({role: "doctor", message: struct.message, createdAt: now});
                    await chat.save();
        
                    if (socket.nsp.adapter.rooms.get(struct.roomNo).size == 1) {
                        let unreadChats = JSON.parse(await getCache(chat.user));
        
                        if (unreadChats && unreadChats[struct.roomNo]) {
                            unreadChats[struct.roomNo] = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: unreadChats[struct.roomNo].unread + 1, createdAt: now};
                        } else if (unreadChats && !unreadChats[struct.roomNo]) {
                            unreadChats[struct.roomNo] = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: 1, createdAt: now};
                        } else {
                            unreadChats = {};
                            unreadChats[struct.roomNo] = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: 1, createdAt: now};
                        }

                        await setCacheForThreeDaysAsync(chat.user, unreadChats);

                        socket.emit("unread_user", "-");
                    } else {
                        socket.to(struct.roomNo).emit("recvChat_user", {role: "doctor", message: struct.message, createdAt: now});
                    }
        
                    return;
                } catch (error) {
                    socket.emit("error", "errorAtSendChat");
        
                    console.log(error, "errorAtSendChat");
                }
            });

            socket.on('disconnect', (data) => {
                
            });

        } catch (error) {
            socket.emit("error", "errorAtInitializing");
            
            console.error(error);

            return;
        }
    } catch (error) {
        if (error.name === "TokenExpiredError") {
            socket.emit("error", "tokenExpiredError");
        }

        return;
    }
};

module.exports = chatting_doctor;