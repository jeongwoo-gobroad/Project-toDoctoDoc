const Redis = require("../../../../config/redisObject");
const jwt = require("jsonwebtoken");

const chatting_doctor_list = async (socket, next) => {
    const token = socket.handshake.query.token;

    console.log("User socket-List view connected");

    try {
        const token_userid = jwt.verify(token, process.env.JWT_SECRET);

        let listener = new Redis();

        await listener.connect();

        listener.redisClient.subscribe(("CHATROOM_DOCTOR_CHANNEL:" + token_userid).toString(), (message, channel) => {
            socket.emit('newChatExists', "newChatExists");
        });

        socket.on("disconnect", async (reason) => {
            await listener.redisClient.unsubscribe(("CHATROOM_DOCTOR_CHANNEL:" + token_userid).toString());
            listener.closeConnnection();
            console.log("successfully disconnected :: list");
        });

        return;
    } catch (error) {
        if (error.name === "TokenExpiredError") {
            socket.emit("error", "tokenExpiredError");
        }

        console.error(error, "errorAtChattingUserList");

        return;
    }
};

module.exports = chatting_doctor_list;