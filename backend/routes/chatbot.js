require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const mainLayout_Admin = "../views/layouts/main_Admin_LoggedIn";
const asyncHandler = require("express-async-handler");
const bcrypt = require("bcrypt");
const openai = require("openai");
const UserSchema = require("../models/User");
const AddressSchema = require("../models/Address");
const mongoose = require("mongoose");
const loginMiddleWare = require("./checkLogin");
const limitMiddleWare = require("./checkLimit");

const User = mongoose.models.User || mongoose.model("User", UserSchema);
const Address = mongoose.model("Address", AddressSchema);
const Doctor = require("../models/Doctor");
const Admin = require("../models/Admin");
const Post = require("../models/Post");
const AIChat = require("../models/AIChat");

router.get(["/"], 
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::Chatbot"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("chatbot/chatbot_main", {pageInfo, accountInfo, layout: mainLayout_LoggedIn});
    })
);

router.get(["/chat"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::Chatbot"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        if (req.query.isResume === 'true') {
            const chatid = req.query.chatid;

            const chat = await AIChat.findById(chatid); 
            const chatList = [];

            /* not to allow unauthorized users */
            if (chat.user != req.session.user._id) {
                res.redirect("/error");

                return;
            }

            for (let i = 0; i < chat.UserResponse.length; i++) {
                chatList.push({
                    'role': 'user',
                    'content': chat.UserResponse[i],
                });
                chatList.push({
                    'role': 'assistant',
                    'content': chat.AIResponse[i],
                })
            }

            res.render("chatbot/chatbot_chat", {pageInfo, accountInfo, chatList, chatid, layout: mainLayout_LoggedIn});
        } else {
            res.render("chatbot/chatbot_chat", {pageInfo, accountInfo, layout: mainLayout_LoggedIn});
        }
    })
);

router.post(["/chatting"],
    loginMiddleWare.ifLoggedInThenProceed,
    limitMiddleWare.ifDailyChatNotExceededThenProceed,
    asyncHandler(async(req, res) => {
        const target = new openai({
            apiKey: process.env.OPENAI_KEY,
        });
        const messages = [
            {
                "role": "developer",
                "content": "너는 전문 심리 상담사이고, 내가 제시하는 걱정들에 대해서 걱정할 필요가 없다는 것을 가능한 한 긍정적으로, 밝고 긍정적인 어휘를 써서, 한국어 경어체체로 말해줘야 해"
            }
        ];
        const wholeMessage = messages.concat(req.body.chattingPrompt);

        // console.log(wholeMessage);

        try {
            
            const completion = await target.chat.completions.create({
                "model": "gpt-4o-mini",
                "store": false,
                "messages": wholeMessage
            });
            

            res.setHeader('Content-Type', 'application/json');
            res.send(JSON.stringify({chat: completion.choices[0].message.content}));

            return;
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

router.post(['/saveChat'],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const target = new openai({
            apiKey: process.env.OPENAI_KEY,
        });

        const {chatData} = req.body;
        let title = "";
        const chat = {
            UserResponse: [], 
            AIResponse: [],
        };
    
        const messages = [
            {
                "role": "developer",
                "content": "너는 전문 심리 상담사이고, 내가 제시하는 걱정들에 대해서 걱정할 필요가 없다는 것을 가능한 한 긍정적으로, 밝고 긍정적인 어휘를 써서서, 한국어 경어체체로 말해줘야 해"
            }
        ];

        const parsed = JSON.parse(chatData);
        const message = messages.concat(parsed);
        const wholeMessage = message.concat([{
            "role": "user",
            "content": "우리가 지금까지 나눈 대화의 제목을 한 줄로 알려 줄 수 있어?"
        }]);

        try {
            const completion = await target.chat.completions.create({
                "model": "gpt-4o-mini",
                "store": false,
                "messages": wholeMessage
            });
            
            title = completion.choices[0].message.content
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }

        const regex = /['"](.*?)['"]/g;
        const titles = title.match(regex).map(match => match.replace(/['"]/g, ''));

        parsed.forEach((talk) => {
            if (talk['role'] === 'user') {
                chat.UserResponse.push(talk['content']);
            } else if (talk['role'] === 'assistant') {
                chat.AIResponse.push(talk['content']);
            }
        });
 
        const pageInfo = {
            title: "Welcome to Mentally::Chatbot::Save",
            contentTitle: titles[0],
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("chatbot/chatbot_save", {pageInfo, accountInfo, chat, layout: mainLayout_LoggedIn});
    })
);

router.post(['/editChat'],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const target = new openai({
            apiKey: process.env.OPENAI_KEY,
        });

        const {chatData, prevChatID} = req.body;
        let title = "";
        const chat = {
            UserResponse: [],
            AIResponse: [],
        };
    
        const messages = [
            {
                "role": "developer",
                "content": "너는 전문 심리 상담사이고, 내가 제시하는 걱정들에 대해서 걱정할 필요가 없다는 것을 가능한 한 긍정적으로, 밝고 긍정적인 어휘를 써서서, 한국어 경어체체로 말해줘야 해"
            }
        ];

        const parsed = JSON.parse(chatData);
        const message = messages.concat(parsed);
        const wholeMessage = message.concat([{
            "role": "user",
            "content": "우리가 지금까지 나눈 대화의 제목을 한 줄로 알려 줄 수 있어?"
        }]);

        try {
            const completion = await target.chat.completions.create({
                "model": "gpt-4o-mini",
                "store": false,
                "messages": wholeMessage
            });
            
            title = completion.choices[0].message.content
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }

        const regex = /['"](.*?)['"]/g;
        const titles = title.match(regex).map(match => match.replace(/['"]/g, ''));

        parsed.forEach((talk) => {
            if (talk['role'] === 'user') {
                chat.UserResponse.push(talk['content']);
            } else if (talk['role'] === 'assistant') {
                chat.AIResponse.push(talk['content']);
            }
        });

        const pageInfo = {
            title: "Welcome to Mentally::Chatbot::Save",
            contentTitle: titles[0],
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("chatbot/chatbot_save", {pageInfo, accountInfo, chat, prevChatID, layout: mainLayout_LoggedIn});
    })
);

router.post(['/chatSaved'],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const {title, chat} = req.body;
        let saved;

        const newChat = new AIChat({
            user: req.session.user._id,
        });

        const parsed = JSON.parse(chat);

        parsed.AIResponse.forEach((talk) => {
            newChat.AIResponse.push(talk);
        });
        parsed.UserResponse.forEach((talk) => {
            newChat.UserResponse.push(talk);
        });

        newChat.title = title;

        try {
            saved = await newChat.save();

            req.session.user = await User.findByIdAndUpdate(req.session.user._id,
                {$push: {ai_chats: saved._id}},
                {new: true},
            );
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }

        res.redirect("/chatbot/chat/" + saved._id);
    })
);

router.patch(['/chatSaved/:id'],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const {title, chat} = req.body;
        const chatid = req.params.id;
        const aiResponse = [];
        const userResponse = [];
        const parsed = JSON.parse(chat);

        const prev = await AIChat.findById(chatid, 'user');

        /* to keep away unauthorized users */
        if (prev.user != req.session.user._id) {
            res.redirect("/error");

            return;
        }

        parsed.AIResponse.forEach((talk) => {
            aiResponse.push(talk);
        });
        parsed.UserResponse.forEach((talk) => {
            userResponse.push(talk);
        });

        try {
            await AIChat.findByIdAndUpdate(chatid, {
                AIResponse: aiResponse,
                UserResponse: userResponse,
                title: title,
                chatEditedAt: Date.now()
            })
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }

        res.redirect("/chatbot/chat/" + chatid);
    })
);

router.get(['/chat/list'],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        try {
            let chats = [];

            for (const chatid of req.session.user.ai_chats) {
                const chat = await AIChat.findById(chatid, 'title _id chatCreatedAt chatEditedAt');

                chats.push(chat);
            }

            chats = chats.sort((a, b) => {
                return new Date(b.date) - new Date(a.date);
            });

            const pageInfo = {
                title: "Welcome to Mentally::Chatbot::My Chat List"
            };
            const accountInfo = {
                id: req.session.user.id,
                usernick: req.session.user.usernick,
                address: req.session.user.address,
                email: req.session.user.email,
            };
            res.render("chatbot/chatbot_list", {pageInfo, accountInfo, chats, layout: mainLayout_LoggedIn});
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

router.get(['/chat/:id'],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        try {
            const chat = await AIChat.findById(req.params.id);

            if (chat && chat.user == req.session.user._id) {
                const pageInfo = {
                    title: "Welcome to Mentally::Chatbot::View"
                };
                const accountInfo = {
                    id: req.session.user.id,
                    usernick: req.session.user.usernick,
                    address: req.session.user.address,
                    email: req.session.user.email,
                };

                res.render("chatbot/chatbot_chatted", {pageInfo, accountInfo, chat, layout: mainLayout_LoggedIn});
            } else {
                res.redirect("/error");

                return;
            }
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

router.delete(['/chat/:id'],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        try {
            const chatid = req.params.id;

            const target = await AIChat.findById(chatid);

            if (target && target.user == req.session.user._id) {
                await AIChat.findByIdAndDelete(chatid);

                req.session.user = await User.findByIdAndUpdate(req.session.user._id, {
                    $pull: {ai_chats: chatid}
                }, {
                    new: true
                })

                res.redirect("/chatbot/chat/list");

                return;
            } else {
                res.redirect("/error");

                return;
            }
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

module.exports = router;