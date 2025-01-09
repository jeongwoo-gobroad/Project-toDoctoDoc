require("dotenv").config;
const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, getTokenInformation } = require("../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn } = require("../checkingMiddleWare");
const { route } = require("../main");
const returnLongLatOfAddress = require("../../../middleware/getcoordinate");
const router = express.Router();

const User = mongoose.model("User", UserSchema);
const Chat = require("../../../models/Chat");
const AIChat = require("../../../models/AIChat");
const { ifDailyChatNotExceededThenProceed } = require("../limitMiddleWare");
const { getLastSegment, getQuote } = require("../../../middleware/usefulFunctions");
const openai = require("openai");

/*
 * 웹 버전의 채팅방과 달리 플러터 버전은 socket.io를 사용하여 실시간 채팅을 구현한다.
 * 그리고 웹 버전과 달리 채팅 내용은 사용자가 삭제를 원하지 않는 이상 항시 저장되도록 구성되어 있다.
*/

router.get(["/list"],
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const user = await getTokenInformation(req, res);

            const userInfo = await User.findById(user.userid).populate('ai_chats', 'title recentMessage chatCreatedAt chatEditedAt _id');

            const chatList = userInfo.ai_chats;

            if (chatList.length < 1) {
                res.status(201).json(returnResponse(false, "listOfAIChatIsEmpty", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "listOfAIChat", chatList));

            return;
        } catch (error) {
            res.status(401).json((returnResponse(true, "errorAtAIList", "-")));

            return;
        }
    }
);

router.get(["/new"],
    checkIfLoggedIn,
    ifDailyChatNotExceededThenProceed,
    async (req, res, next) => {
        try {
            const user = await getTokenInformation(req, res);

            const aichat = await AIChat.create({user: user.userid});
            await User.findByIdAndUpdate(user.userid, {
                $push: {ai_chats: aichat._id}
            });

            const chatid = aichat._id;

            const target = new openai({
                apiKey: process.env.OPENAI_KEY,
            });

            const message = [
                {
                    "role": "developer",
                    "content": "너는 전문 심리 상담사이고, 내가 제시하는 걱정들에 대해서 걱정할 필요가 없다는 것을 가능한 한 긍정적으로, 밝고 긍정적인 어휘를 써서, 한국어 경어체로 말해줘야 해"
                },
                {
                    "role": "user",
                    "content": "안녕"
                }
            ];

            const completion = await target.chat.completions.create({
                "model": "gpt-4o-mini",
                "store": false,
                "messages": message
            });

            const startingMessage = completion.choices[0].message.content;

            await AIChat.findByIdAndUpdate(chatid, {
                $push: {
                    response: 
                    {
                        role: 'assistant',
                        content: startingMessage
                    }
                },
                recentMessage: startingMessage,
            });

            res.status(200).json(returnResponse(false, "newAiChat", {chatid: chatid, startingMessage: startingMessage}));

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
            const user = await getTokenInformation(req, res);

            const aichat = await AIChat.findById(req.params.chatid);

            if (aichat.user != user.userid) {
                res.status(401).json(returnResponse(true, "notYourChat", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "getAiChat", aichat));

            return;
        } catch (error) {
            res.status(401).json(returnResponse(true, "errorAtGetAiChat", "-"));

            return;
        }
    }
);

router.post(["/save"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const {chatid} = req.body;

        const user = await getTokenInformation(req, res);

        try {
            const chat = await AIChat.findById(chatid);

            if (!chat) {
                res.status(401).json(returnResponse(true, "noSuchChat", "-"));
    
                return;
            }
            if (chat.user != user.userid) {
                res.status(402).json(returnResponse(true, "notYourChat", "-"));
    
                return;
            }
    
            let messages = [
                {
                    "role": "developer",
                    "content": "너는 전문 심리 상담사이고, 내가 제시하는 걱정들에 대해서 걱정할 필요가 없다는 것을 가능한 한 긍정적으로, 밝고 긍정적인 어휘를 써서, 한국어 경어체로 말해줘야 해"
                }
            ];
    
            messages = messages.concat(chat.response);
            messages = messages.concat([{"role": "user", "content": "지금까지 나눈 대화에 어울리는 제목을 쌍따옴표 안에 넣어서 알려줘"}]);

            const target = new openai({
                apiKey: process.env.OPENAI_KEY,
            });
            const completion = await target.chat.completions.create({
                "model": "gpt-4o-mini",
                "store": false,
                "messages": messages
            });

            // console.log(completion.choices[0].message.content);

            title = getQuote(completion.choices[0].message.content);

            await AIChat.findByIdAndUpdate(chatid, {
                title: title
            });

            res.status(200).json(returnResponse(false, "saveAiChat", {title: title}));

            return;
        } catch (error) {
            console.error(error, "errorAtAiChatSaving");

            res.status(403).json(returnResponse(true, "errorAtAiChatSaving", "-"));

            return;
        }
    }
);

router.delete(["/delete/:chatid"], 
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const chat = await AIChat.findById(req.params.chatid);

        // console.log(chat);
        // console.log("www");

        if (!chat) {
            res.status(401).json(returnResponse(true, "noSuchChat", "-"));

            return;
        }
        if (chat.user != user.userid) {
            res.status(402).json(returnResponse(true, "notYourChat", "-"));

            return;
        }

        try {
            await AIChat.findByIdAndDelete(req.params.chatid);
            await User.findByIdAndUpdate(user.userid, {
                $pull: {ai_chats: req.params.chatid}
            });

            res.status(200).json(returnResponse(false, "aichatdeleted", "-"));
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDelete", "-"));

            console.error(error, "errorAtAiChatDelete");

            return;
        }
    }
);

const aiChatting = async (socket, next) => {
    // const token = socket.handshake.query.token;

    const chatid = socket.handshake.query.chatid;
    const roomNo = chatid;

    const userid = await AIChat.findById(chatid).user;
    // const token_userid = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findById(userid);

    // if (userid != token_userid.userid) {
    //     return;
    // }

    // console.log("Phase 1");

    // console.log(socket);

    // if (!user.isPremium) {
    //     const limits = user.limits;
    //     const current = new Date();

    //     if (limits.dailyChatDate.toDateString() !== current.toDateString()) {
    //         limits.dailyChatDate = current;
    //         limits.dailyChatCount = 0;
    //     }

    //     if (limits.dailyChatCount >= 10) {
    //         socket.emit('aichat', "일일 대화 한도가 초과되었습니다. 무료 계정은 하루에 10개의 말풍선만을 사용할 수 있습니다.");

    //         return;
    //     }
    // }
    
    // await socket.join(roomNo);

    socket.on('aichat', async (data) => {
        const sentence = data;

        // console.log("Phase 2");

        const target = new openai({
            apiKey: process.env.OPENAI_KEY,
        });

        const messages = [
            {
                "role": "developer",
                "content": "너는 전문 심리 상담사이고, 내가 제시하는 걱정들에 대해서 걱정할 필요가 없다는 것을 가능한 한 긍정적으로, 밝고 긍정적인 어휘를 써서, 한국어 경어체로 말해줘야 해"
            }
        ];

        try {
            const prevChat = await AIChat.findByIdAndUpdate(roomNo, {
                $push: {
                    response: {
                        "role": "user",
                        "content": sentence
                    }
                },
                chatEditedAt: Date.now()
            }, {new: true});

            // console.log(messages.concat(prevChat.response));

            const completion = await target.chat.completions.create({
                "model": "gpt-4o-mini",
                "store": false,
                "messages": messages.concat(prevChat.response)
            });

            const response = completion.choices[0].message.content;

            prevChat.response.push(
                {
                    role: "assistant",
                    content: response
                }
            );

            if (prevChat.response.length > 40) {
                prevChat.response.shift();
            }

            await AIChat.findByIdAndUpdate(roomNo, {
                response: prevChat.response,
                chatEditedAt: Date.now(),
                recentMessage: response,
            });

            socket.emit("aichat", response);

            return;
        } catch (error) {
            console.error(error, "errorAtAiChatting");

            return;
        }
    })
};

module.exports = {router, aiChatting};