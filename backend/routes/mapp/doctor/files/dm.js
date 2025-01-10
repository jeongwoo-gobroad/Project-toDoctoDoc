const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../../models/User");
const returnResponse = require("../../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, generateRefreshToken, getTokenInformation } = require("../../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn, ifPremiumThenProceed, isDoctorThenProceed } = require("../../checkingMiddleWare");
const returnLongLatOfAddress = require("../../../../middleware/getcoordinate");
const router = express.Router();
const Doctor = require("../../../../models/Doctor");
const Chat = require("../../../../models/Chat");
const User = mongoose.model("User", UserSchema);

router.get(["/dm/list"], 
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        try {
            const usr = await Doctor.findById(user.userid).populate(
                [
                    {path: 'chats', populate: {path: 'user', select: 'usernick'}}
                ]
            );

            const chats = usr.chats;

            if (chats.length > 0) {
                res.status(200).json(returnResponse(false, "returnedChatList", chats));
    
                return;
            } else {
                res.status(201).json(returnResponse(false, "emptyChatList", "-"));
    
                return;
            }
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDMLists", "-"));
        }
    }
);

router.get(["/dm"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const {uid, did} = req.query;
        const user = await getTokenInformation(req, res);

        if (user.userid != did) {
            res.status(401).json(returnResponse(true, "notYourChat", "-"));

            return;
        }

        try {
            const chat = await Chat.findOne({user: uid, doctor: did});

            if (chat) {
                res.status(200).json(returnResponse(false, "returnedChatID", {chatid: chat._id}));

                return;
            } else {
                const newChat = await Chat.create({
                    user: uid,
                    doctor: did,
                });
                await User.findByIdAndUpdate(uid, {
                    $push: {chats: newChat._id}
                });
                await Doctor.findByIdAndUpdate(did, {
                    $push: {chats: newChat._id}``
                });

                res.status(200).json(returnResponse(false, "returnedNewChatID", {chatid: newChat._id}));

                return;
            }
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDMMainRoute", "-"));

            return;
        }
    }
);

router.get(["/dm/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const chatid = req.params.id;
        const user = await getTokenInformation(req, res);
        try {
            const chat = await Chat.findById(chatid);

            if (!chat) {
                res.status(401).json(returnResponse(true, "noSuchChat", "-"));

                return;
            }

            if (chat.doctor != user.userid) {
                res.status(402).json(returnResponse(true, "notYourChat", "-"));

                return;
            }

            res.status(200).json(returnResponse(false, "returnedExistingChat", chat));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDMDetailsReturn", "-"));

            return;
        }
    }
);

router.delete(["/dm/:id"],
    checkIfLoggedIn,
    isDoctorThenProceed,
    async (req, res, next) => {
        const chatid = req.params.id;
        const user = await getTokenInformation(req, res);
        try {
            const chat = await Chat.findById(chatid);

            if (!chat) {
                res.status(401).json(returnResponse(true, "noSuchChat", "-"));

                return;
            }

            if (chat.doctor != user.userid) {
                res.status(402).json(returnResponse(true, "notYourChat", "-"));

                return;
            }

            const usr = chat.user;
            const doc = chat.doctor;
            await Chat.findByIdAndDelete(chatid);
            await User.findByIdAndUpdate(usr, {
                $pull: {chats: chatid}``
            });
            await Doctor.findByIdAndUpdate(doc, {
                $pull: {chats: chatid}
            });

            res.status(200).json(returnResponse(false, "deletedExistingChat", chat));

            return;
        } catch (error) {
            res.status(403).json(returnResponse(true, "errorAtDMDelete", "-"));

            return;
        }
    }
);

module.exports = router;