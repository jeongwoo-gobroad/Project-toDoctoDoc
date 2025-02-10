const express = require("express");
const { checkIfLoggedIn, isDoctorThenProceed } = require("../../checkingMiddleWare");
const { getTokenInformation } = require("../../../auth/jwt");
const Chat = require("../../../../models/Chat");
const returnResponse = require("../../standardResponseJSON");
const { getCache } = require("../../../../middleware/redisCaching");
const UserSchema = require("../../../../models/User");
const mongoose = require("mongoose");
const Doctor = require("../../../../models/Doctor");
const Appointment = require("../../../../models/Appointment");
const User = mongoose.model('User', UserSchema);
const router = express.Router();

router.get(["/list"], 
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const usr = await Doctor.findById(req.userid, '-chatList').populate({
                path: 'chats',
                populate: {
                    path: 'user',
                    select: 'usernick'
                }
            });
            const chats = usr.chats;
            const previews = [];

            for (const chat of chats) {
                const prevChat = {};
                let cache;

                prevChat.userId = chat.user._id;
                prevChat.userName = chat.user.usernick;
                prevChat.date = chat.date;
                prevChat.cid = chat._id;
                prevChat.isBanned = chat.isBannedByUser || chat.isBannedByDoctor;

                if (prevChat.isBanned) {
                    prevChat.recentChat = {role: "system", message: "차단된 대화입니다.", createdAt: chat.date, autoIncrementId: -1};
                    prevChat.unreadChat = -1;
                } else {
                    if ((cache = await getCache("CHATROOM:RECENT:" + chat._id))) {
                        prevChat.recentChat = cache;
                    } else {
                        prevChat.recentChat = {role: "system", message: "최근 채팅이 없거나 오래되었습니다.", createdAt: chat.date, autoIncrementId: -1};
                    }
                    previews.push(prevChat);
                }
            }

            res.status(200).json(returnResponse(false, "chatList", previews));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDoctorChatListing", "-"));

            console.error(error, "errorAtDoctorChatListing");

            return;
        }
    }
);

router.delete(["/delete/:cid"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const chat = await Chat.findById(req.params.cid);

            if (!chat) {
                res.status(401).json(returnResponse(true, "noSuchChat", "-"));

                return;
            }

            await Doctor.findByIdAndUpdate(user.userid, {
                $pull: {chats: chat._id}
            });
            await User.findByIdAndUpdate(chat.user, {
                $pull: {chats: chat._id}
            });
            await Chat.findByIdAndDelete(chat._id);

            res.status(200).json(returnResponse(false, "chatDeleted", "-"));
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDoctorChatDeleting", "-"));

            console.error(error, "errorAtDoctorChatDeleting");

            return;
        }
    }
);

router.post(["/ban"], 
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const {chatId} = req.body;

        try {
            const chat = await Chat.findById(chatId);

            if (!chat) {
                res.status(401).json(returnResponse(true, "noSuchChat", "-"));

                return;
            }

            chat.isBannedByDoctor = true;

            await chat.save();

            res.status(200).json(returnResponse(false, "chatBanned", "-"));
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDoctorChatBan", "-"));

            console.error(error, "errorAtDoctorChatBan");

            return;
        }
    }
);

router.get(["/banList"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const usr = await Doctor.findById(user.userid).populate({
                path: 'chats',
                select: '-chatList'
            });

            const chats = [];

            for (const chat of usr.chats) {
                if (chat.isBannedByDoctor || chat.isBannedByUser) {
                    chats.push(chat);
                }
            }

            res.status(200).json(returnResponse(false, "userBanList", chats));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtUserBanList", "-"));

            console.error(error, "errorAtUserBanList");
            
            return;
        }
    }
);

router.delete(["/unBan"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);
        const {chatId} = req.body;

        try {
            const chat = await Chat.findById(chatId, '-chatList');

            if (!chat) {
                res.status(401).json(returnResponse(true, "noSuchChat", "-"));
                
                return;
            }

            if (!chat.isBannedByDoctor) {
                res.status(402).json(returnResponse(true, "notBannedChat", "-"));
                
                return;
            }

            chat.isBannedByDoctor = false;

            await chat.save();

            res.status(200).json(returnResponse(false, "chatUnBanned", "-"));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtUserUnBan", "-"));

            console.error(error, "errorAtUserUnBan");
            
            return;
        }
    }
);

router.get(["/appointmentStatus/:appid"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        try {
            const appointment = await Appointment.findById(req.params.appid);

            if (!appointment) {
                res.status(401).json(returnResponse(true, "noSuchAppointment", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "appointmentStatus", appointment.isAppointmentApproved));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDoctorAppointmentStatus", "-"));

            console.error(error, "errorAtDoctorAppointmentStatus");

            return;
        }
    }
);

module.exports = router;