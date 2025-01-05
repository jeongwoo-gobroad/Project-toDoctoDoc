require('dotenv').config();
const io = require('socket.io');
const { getLastSegment } = require('../../middleware/usefulFunctions');
const Chat = require('../../models/Chat');
const { getTokenInformation_web } = require('../web_auth/jwt_web');
const { verify } = require('jsonwebtoken');

const authSocket = async (socket, next) => {
    const token = socket.handshake.query.token;

    const req = socket.request;
    const {
        headers: {referer}
    } = req;

    const roomNo = getLastSegment(referer);

    try {
        const chat = await Chat.findById(roomNo, 'user doctor');

        const user = verify(token, process.env.JWT_SECRET); 

        if (chat.user == user.userid || chat.doctor == user.userid) {
            console.log("hi");
            next();
        } 

        return;
    } catch (error) {
        console.error(error);

        next(error);

        return; 
    }
};

module.exports = authSocket;