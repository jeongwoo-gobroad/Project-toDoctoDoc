const express = require("express");
const { checkIfLoggedIn } = require("../../checkingMiddleWare");
const { getTokenInformation } = require("../../../auth/jwt");
const Chat = require("../../../../models/Chat");
const returnResponse = require("../../standardResponseJSON");
const { getCache } = require("../../../../middleware/redisCaching");
const { Queue } = require("bullmq");
const UserSchema = require("../../../../models/User");
const mongoose = require("mongoose");
const Doctor = require("../../../../models/Doctor");
const Appointment = require("../../../../models/Appointment");
const User = mongoose.model('User', UserSchema);
const router = express.Router();

router.post(["/curateScreen"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const {doctorId} = req.body;
        const user = await getTokenInformation(req, res);

        try {
            const chat = await Chat.findOne({user: user.userid, doctor: doctorId});

            if (!chat) {
                const newChat = await Chat.create({
                    user: user.userid,
                    doctor: doctorId,
                });

                await User.findByIdAndUpdate(user.userid, {
                    $push: {chats: newChat._id}
                });
                await Doctor.findByIdAndUpdate(doctorId, {
                    $push: {chats: newChat._id}
                });

                res.status(200).json(returnResponse(false, "chatRoomCode", newChat._id));

                return;
            }

            res.status(200).json(returnResponse(false, "chatRoomCode", chat._id));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtCurateToChat", "-"));

            console.error(error, "errorAtCurateToChat");

            return;
        }
    }
);

router.get(["/list"], 
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const usr = await User.findById(user.userid).populate({
                path: 'chats',
                populate: {
                    path: 'doctor',
                    select: 'name'
                }
            });
            const chats = usr.chats;
            const previews = [];

            for (const chat of chats) {
                const prevChat = {};
                let cache;

                prevChat.doctorId = chat.doctor._id;
                prevChat.doctorName = chat.doctor.name;
                prevChat.date = chat.date;
                prevChat.cid = chat._id;
                prevChat.isBanned = chat.isBanned;

                if (chat.isBanned) {
                    prevChat.recentChat = "차단된 대화입니다.";
                    prevChat.unreadChat = -1;
                } else {
                    if ((cache = await getCache("ROOM:" + chat._id))) {
                        prevChat.recentChat = cache;
    
                        const messageQueue = new Queue(chat._id + "_DOCTOR", {
                            connection: {
                                host: process.env.RS_HOST,
                                port: process.env.RS_PORT,
                                username: process.env.RS_USERNAME,
                                password: process.env.RS_NONESCAPE_PASSWORD,
                            },
                            defaultJobOptions: {
                                removeOnComplete: true,
                                removeOnFail: true,
                            }
                        });
    
                        prevChat.unreadChat = await messageQueue.count();
    
                        messageQueue.close();
                    } else {
                        prevChat.recentChat = "최근 채팅이 없거나 오래되었습니다.";
                        prevChat.unreadChat = -1;
                    }
                    previews.push(prevChat);
                }
            }

            res.status(200).json(returnResponse(false, "chatList", previews));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtUserChatListing", "-"));

            console.error(error, "errorAtUserChatListing");

            return;
        }
    }   
);

router.delete(["/delete/:cid"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const chat = await Chat.findById(req.params.cid);

            if (!chat) {
                res.status(401).json(returnResponse(true, "noSuchChat", "-"));

                return;
            }

            await User.findByIdAndUpdate(user.userid, {
                $pull: {chats: chat._id}
            });
            await Doctor.findByIdAndUpdate(chat.doctor, {
                $pull: {chats: chat._id}
            });
            await Chat.findByIdAndDelete(chat._id);

            res.status(200).json(returnResponse(false, "chatDeleted", "-"));
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtUserChatDeleting", "-"));

            console.error(error, "errorAtUserChatDeleting");

            return;
        }
    }
);

router.post(["/ban"], 
    checkIfLoggedIn,
    async (req, res, next) => {
        const {chatId} = req.body;

        try {
            const chat = await Chat.findById(chatId);

            if (!chat) {
                res.status(401).json(returnResponse(true, "noSuchChat", "-"));

                return;
            }

            chat.isBanned = true;

            await chat.save();

            res.status(200).json(returnResponse(false, "chatBanned", "-"));
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtUserChatBan", "-"));

            console.error(error, "errorAtUserChatBan");

            return;
        }
    }
);

router.get(["/appointmentStatus/:cid"],
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
            const chat = await Chat.findById(req.params.cid).populate({
                path: 'appointment',
                select: 'isAppointmentApproved'
            });
            const appointment = await Appointment.findById(chat.appointment);

            if (!chat.appointment) {
                res.status(401).json(returnResponse(true, "noAppointment", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "appointmentStatus", chat.appointment.isAppointmentApproved));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDoctorAppointmentStatus", "-"));

            console.error(error, "errorAtDoctorAppointmentStatus");

            return;
        }
    }
);

module.exports = router;