require('dotenv').config({path: "./_secrets/dotenv/.env"});
const {Worker} = require('worker_threads');
const express = require('express');
const http = require('http');
const router = express.Router();

const app = express();
const server = http.createServer(app);

const returnResponse = require("./dmWorks/functions/standardResponseJSON");
const { checkIfLoggedIn, checkIfMyChat } = require('./middlewares/checkingMiddleware');

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

        console.log(req.userid + " has connected");
        
        try {
            if (map.has(req.params.cid)) {
                let people = map.get(req.params.cid);
                people++;
                map.set(req.params.cid, people);
                worker = threadPool.get(req.params.cid);
            } else {
                map.set(req.params.cid, 1);
                worker = new Worker("./dmWorks/mqManagement.js", {workerData: {chatId: req.params.cid}});
                threadPool.set(req.params.cid, worker);
            }
    
            const message = await getPreviousChat(worker, readedUntil);
    
            res.status(200).json(returnResponse(false, "returnedPreviousChat", message));
    
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
            let people = map.get(req.params.cid);

            people--;

            if (people === 0) {
                map.delete(req.params.cid);
                const worker = threadPool.get(req.params.cid);
                worker.terminate();
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

server.listen(5000, () => {
    console.log('Server working on port 5000');
});