const express = require('express');
const { checkIfLoggedIn } = require('../../checkingMiddleWare');
const UserSchema = require('../../../../models/User');
const mongoose = require('mongoose');
const AIChat = require('../../../../models/AIChat');
const Chat = require('../../../../models/Chat');
const Comment = require('../../../../models/Comment');
const Curate = require('../../../../models/Curate');
const PatientMemo = require('../../../../models/PatientMemo');
const Post = require('../../../../models/Post');
const Review = require('../../../../models/Review');
const Schedule = require('../../../../models/Schedule');
const returnResponse = require('../../standardResponseJSON');
const Redis = require('../../../../config/redisObject');
const User = mongoose.model('User', UserSchema);
const router = express.Router();

router.get(["/memberDelete"],
    checkIfLoggedIn,
    async (req, res, next) => {
        try {
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

            res.status(200).json(returnResponse(false, "accountAndInformationDeleted", "-"));

            redis.closeConnnection();
            redis = null;

            return;
        } catch (error) {
            console.error(error, "errorAtMemberDelete");

            res.status(500).json(returnResponse(true, "errorAtMemberDelete", "-"));

            return;
        }
    }
);

module.exports = router;