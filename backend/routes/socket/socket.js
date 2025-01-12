const SocketIO = require("socket.io");

const setServer = (server) => {
    const io = SocketIO(server, {
        path: '/msg',
        cors: {
            origin: "*",
            methods: ["GET", "POST"]
        },
    });

    return io;
};

module.exports = {setServer};