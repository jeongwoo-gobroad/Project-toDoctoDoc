const Chat = require("../models/Chat");
const { getLastSegment } = require("./usefulFunctions");

require("dotenv").config();


const chatting = async (socket, next) => {
    const req = socket.request;
    const {
        headers: {referer}
    } = req;

    // console.log(socket.handshake);

    const roomNo = getLastSegment(referer);

    socket.join(roomNo);

    // console.log(roomNo);

    socket.on('dm', async (data) => {
        const sentence = data.split(':');
        // console.log(sentence[0] + ":" + sentence[1]);
        socket.broadcast.to(roomNo).emit('dm', sentence[1]);
        await Chat.findByIdAndUpdate(roomNo, {
            $push: {chatList: {
                "role": sentence[0],
                "message": sentence[1]
            }},
            date: Date.now()
        });
    });

    next();
}

module.exports = chatting;