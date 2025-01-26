const { default: mongoose } = require("mongoose");
const redis = require("../../../config/redis");
const Chat = require("../../../models/Chat");
const UserSchema = require("../../../models/User");
const Doctor = require("../../../models/Doctor");
const User = mongoose.model('User', UserSchema);
const jwt = require("jsonwebtoken");
const { setCacheForThreeDaysAsync, getCache } = require("../../../middleware/redisCaching");
const sendDMPushNotification = require("../push/dmPush");


const chatting_user = async (socket, next) => {
    const token = socket.handshake.query.token;

    try {
        const token_userid = jwt.verify(token, process.env.JWT_SECRET);

        const userid = token_userid.userid;

        try {
            const state = User.findById(userid);
    
            if (!state) {
                socket.emit("error", "noSuchUserID");
    
                return;
            }
    
            // console.log("Phase 1");
        
            socket.on('joinChat_user', async (data) => {
                try {
                    const roomNo = data;
                    let unread = -1;
        
                    const chat = await Chat.findById(roomNo);
        
                    if (chat.user != userid) {  
                        socket.emit("error", "notYourChat");
        
                        return;
                    }
    
                    // console.log("Phase 2");
        
                    socket.join(roomNo);
        
                    const unreadChats = JSON.parse(await redis.redisClient.get(userid));
                    if (unreadChats && unreadChats.roomNo) {
                        unread = unreadChats.unread;
                        delete unreadChats.roomNo;
                        // await redis.redisClient.set(userid, unreadChats);
                        await setCacheForThreeDaysAsync(userid, unreadChats);
                    }
                    
                    socket.emit("returnJoinedChat_user", {chat: chat, unread: unread});
                } catch (error) {
                    socket.emit("error", "errorAtJoinChat");
        
                    console.log(error, "errorAtJoinChat");
                }
            });
        
            socket.on('leaveChat_user', async (data) => {
                try {
                    const roomNo = data;
        
                    socket.leave(roomNo);
        
                    socket.emit("returnLeftChat", "-");
                } catch (error) {
                    socket.emit("error", "errorAtLeaveChat");
        
                    console.log(error, "errorAtLeaveChat");
                }
            });
        
            socket.on('sendChat_user', async (data) => {
                try {
                    const struct = JSON.parse(data);
        
                    const chat = await Chat.findById(struct.roomNo).populate('doctor', 'pushTokens');
                    const now = Date.now();
        
                    if (chat.user != userid) {  
                        socket.emit("error", "notYourChat");
        
                        return;
                    }
                    // console.log("Patient: ", struct.roomNo);
                    // console.log(socket.nsp.adapter.rooms.get(struct.roomNo).size);
                    // console.log("Phase 4")
         
                    chat.chatList.push({role: "user", message: struct.message, createdAt: now});
                    await chat.save();
        
                    if (socket.nsp.adapter.rooms.get(struct.roomNo).size == 1) {
                        let unreadChats = JSON.parse(await getCache(chat.doctor._id));

                        if (unreadChats && unreadChats[struct.roomNo]) {
                            unreadChats[struct.roomNo] = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: unreadChats[struct.roomNo].unread + 1, createdAt: now};
                        } else if (unreadChats && !unreadChats[struct.roomNo]) {
                            unreadChats[struct.roomNo] = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: 1, createdAt: now};
                        } else {
                            unreadChats = {};
                            unreadChats[struct.roomNo] = {recentMessage: chat.chatList[chat.chatList.length - 1], unread: 1, createdAt: now};
                        }

                        await setCacheForThreeDaysAsync(chat.doctor._id, unreadChats);

                        await sendDMPushNotification(chat.doctor.deviceIds, {title: "읽지 않은 환자로부터의 DM", body: chat.chatList[chat.chatList.length - 1]});
    
                        socket.emit("unread_doctor", "-");

                        // console.log("user:: solo");
                    } else {
                        socket.to(struct.roomNo).emit("recvChat_doctor", {role: "user", message: struct.message, createdAt: now});
                        // console.log("user:: both");
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

module.exports = chatting_user;