require('dotenv').config();
const io = require('socket.io');

const authSocket = (socket, next) => {
    const token = socket.handshake.query.token;

    console.log(token);
};