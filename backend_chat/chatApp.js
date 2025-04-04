require('dotenv').config({path: "./_secrets/dotenv/.env"});
const {Worker} = require('worker_threads');
const express = require('express');
const http = require('http');
const router = express.Router();
const axios = require('axios');
const cors = require('cors');
const returnResponse = require("./dmWorks/functions/standardResponseJSON");
const { checkIfLoggedIn, checkIfMyChat } = require('./middlewares/checkingMiddleware');
const connectDB = require('./config/mongo');
const EventEmitter = require('events');
const { connectRedis, doesKeyExist, doesAtLeastOneUserExist } = require('./config/redis-singleton');
const Chat = require('./models/Chat');

connectDB();
connectRedis();

const app = express();
const server = http.createServer(app);
const port = process.env.SERVER_PORT || 5000;

EventEmitter.setMaxListeners(0);

app.use(cors());

const map = new Map();
const threadPool = new Map();

const getPreviousChat = (worker, readedUntil) => {
    return new Promise((resolve, reject) => {
        try {
            worker.postMessage(readedUntil);
            worker.on('message', (chatList) => {
                resolve(chatList);
            });
        } catch (error) {
            reject(error);
        }
    });
}

router.get(["/mapp/dm/joinChat/:cid"],
    checkIfLoggedIn,
    checkIfMyChat,
    async (req, res, next) => {
        let worker;
        const {readedUntil} = req.query;

        // console.log(req.userid + " has connected");
        
        try {
            if (map.has(req.params.cid)) {
                let people = map.get(req.params.cid);
                people++;
                map.set(req.params.cid, people);
                worker = threadPool.get(req.params.cid);
            } else {
                let chats = null;
                try {
                    chats = await Chat.findById(req.params.cid);
                } catch (error) {
                    console.error(error, "errorAtJoinChat");

                    return;
                }
                map.set(req.params.cid, 1);
                worker = new Worker("./dmWorks/mqManagement.js", {workerData: {
                    chatId: req.params.cid,
                    userId: chats.user,
                    doctorId: chats.doctor
                }});
                threadPool.set(req.params.cid, worker);
            }
    
            const message = await getPreviousChat(worker, readedUntil);
    
            res.status(200).json(returnResponse(false, "returnedPreviousChat", JSON.parse(message)));
    
            return;
        } catch (error) {
            console.error(error, "errorAtJoinChat");

            res.status(403).json(returnResponse(true, "errorAtJoinChat", "-"));

            return;
        }
    }
);

router.get(["/mapp/dm/leaveChat/:cid"],
    checkIfLoggedIn,
    checkIfMyChat,
    (req, res, next) => {
        if (map.has(req.params.cid)) {
            try {
                let people = map.get(req.params.cid);

                people--;

                map.set(req.params.cid, people);

                if (people === 0) {
                    map.delete(req.params.cid);
                    const worker = threadPool.get(req.params.cid);
                    threadPool.delete(req.params.cid);
                    worker.terminate();
                }
            } catch (error) {
                console.error(error, "errorAtLeaveChat:Mid");

                res.status(201).json(returnResponse(true, "errorHasHappenedWhileLeavingTheChat", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "leftChat", "-"));
            
            return;
        } else {
            console.error(error, "errorAtLeaveChat");

            res.status(403).json(returnResponse(true, "errorAtLeaveChat", "-"));

            return;
        }

        return;
    }
);

app.use(router);

app.use((req, res, next) => {
    res.status(404).json(returnResponse(true, "noSuchPage", "-"));

    return;
});
app.use((err, req, res, next) => {
    res.status(500).json(returnResponse(true, "Internal Server Error", err));

    return;
})

axios.get('https://myexternalip.com/raw')
    .then((response) => {
        console.log(response.data);
    })
    .catch((error) => {
        console.error(error, "errorAtCurlMyIP");
    });

server.listen(port, () => {
    console.log(`Server working on port ${port}`);
});


/* To iterate and check if unnecessary chatrooms are still in the memory and thread pool */
setInterval(async () => {
    try {
        for (const [key, val] of map) {
            if (!(await doesKeyExist("CHAT:MEMBER:" + key)) || !(await doesAtLeastOneUserExist(key))) {
                map.delete(key);
                const worker = threadPool.get(key);
                threadPool.delete(key);
                worker.terminate();
            }
        }
    } catch (error) {
        console.error(error, "errorAtSetInterval");
    }
}, 10000);