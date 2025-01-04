const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken } = require("../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn } = require("../checkingMiddleWare");
const { route } = require("../main");
const returnLongLatOfAddress = require("../../../middleware/getcoordinate");
const router = express.Router();

const User = mongoose.model("User", UserSchema);
const Chat = require("../../../models/Chat");
const AIChat = require("../../../models/AIChat");
const { ifDailyChatNotExceededThenProceed } = require("../limitMiddleWare");

/*
 * 웹 버전의 채팅방과 달리 플러터 버전은 socket.io를 사용하여 실시간 채팅을 구현한다.
 * 그리고 웹 버전과 달리 채팅 내용은 사용자가 삭제를 원하지 않는 이상 항시 저장되도록 구성되어 있다.
*/

router.get(["/new"],
    checkIfLoggedIn,
    ifDailyChatNotExceededThenProceed,
    async (req, res, next) => {
        try {
            const aichat = await AIChat.create({});

            const chatid = aichat._id;

            res.status(200).json(returnResponse(false, "newAiChat", {chatid}));

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "errorAtNewAiChat", "-"));

            return;
        }
    }
);

router.get(["/get/:chatid"],
    checkIfLoggedIn,
    ifDailyChatNotExceededThenProceed,
    async (req, res, next) => {
        try {
            const aichat = await AIChat.findById(req.params.chatid);

            res.status(200).json(returnResponse(false, "getAiChat", aichat));

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "errorAtGetAiChat", "-"));

            return;
        }
    }
);

module.exports = router;