const express = require('express');
const returnResponse = require('./mapp/standardResponseJSON');
const router = express.Router();
const bcrypt = require("bcrypt");
const UserSchema = require('../models/User');
const mongoose = require('mongoose');
const Redis = require('../config/redisObject');
const AIChat = require('../models/AIChat');
const Chat = require('../models/Chat');
const Curate = require('../models/Curate');
const PatientMemo = require('../models/PatientMemo');
const Post = require('../models/Post');
const Review = require('../models/Review');
const Schedule = require('../models/Schedule');
const User = mongoose.model('User', UserSchema);
const mainLayout = "../views/layouts/main";

router.get(["/accountDeletion"],
    async (req, res, next) => {
        try {
            res.render("user_auth/account_deletion", {layout: false});

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtAccountDeletionGET", "-"));

            console.log(error, "errorAtAccountDeletionGET");

            return;
        }
    }
);

router.delete(["/accountDeletion"],
    async (req, res, next) => {
        try {
            const {userId, password} = req.body;

            const user = await User.findOne({id: userId});

            if (user && bcrypt.compare(password, user.password)) {
                let redis = new Redis();
                await redis.connect();
                await AIChat.deleteMany({user: req.userid});
                const chats = await Chat.find({user: req.userid});
                for (const chat of chats) {
                    await redis.delCache("CHAT:MEMBER:" + chat._id);
                    await redis.delCache("CHATROOM:CNTER:" + chat._id);
                    await redis.delCache("CHATROOM:RECENT:" + chat._id);
                }
                await redis.delCache("VIEW:" + req.userid);
                await Chat.deleteMany({user: req.userid});
                await Curate.deleteMany({user: req.userid});
                await PatientMemo.deleteMany({user: req.userid});
                await Post.deleteMany({user: req.userid});
                await Review.deleteMany({user: req.userid});
                await Schedule.deleteMany({userid: req.userid, isDoctor: false, isCounselor: false});
                await User.deleteOne({_id: req.userid});

                res.status(200).json(returnResponse(false, "accountDeleted", "-"));

                return;
            }

            res.status(401).json(returnResponse(true, "noSuchAccountOrWrongPassword", "-"));

            return;
        } catch (error) {
            res.status(500).json(returnResponse(true, "errorAtAccountDeletionDELETE", "-"));

            console.log(error, "errorAtAccountDeletionDELETE");

            return;
        }
    }
);

module.exports = router;