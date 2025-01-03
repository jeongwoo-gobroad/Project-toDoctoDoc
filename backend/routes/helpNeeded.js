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
const Curate = require("../models/Curate");

router.get(["/"], 
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::마음이 아파요"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("helpNeeded_user/helpNeeded_user_main", {pageInfo, accountInfo, layout: mainLayout_LoggedIn});

        return;
    })
);

router.get(["/around"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res, next) => {
        const userLong = req.session.user.address.longitude;
        const userLat  = req.session.user.address.latitude;
        const arnd = parseFloat(req.query.km);

        const nearDoctors = await Doctor.find({
            $and: [
                {
                    'address.longitude': 
                    {
                        $gte: userLong - parseFloat(process.env.LONG_ONE_KM) * arnd,
                        $lte: userLong + parseFloat(process.env.LONG_ONE_KM) * arnd
                    }
                },
                {
                    'address.latitude':
                    {
                        $gte: userLat - parseFloat(process.env.LAT_ONE_KM) * arnd,
                        $lte: userLat + parseFloat(process.env.LAT_ONE_KM) * arnd
                    }
                },
                {
                    isVerified: true,
                }
            ]
        });

        // console.log(userLong - parseFloat(process.env.LONG_ONE_KM), userLong + parseFloat(process.env.LONG_ONE_KM));

        const pageInfo = {
            title: "Welcome to Mentally::주변 주치의 찾기"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };
 
        res.render("helpNeeded_user/helpNeeded_user_around", {pageInfo, accountInfo, arnd, nearDoctors, layout: mainLayout_LoggedIn});

        return;
    }),
    loginMiddleWare.errorOccured
);

router.get(['/curate'],
    loginMiddleWare.ifLoggedInThenProceed,
    limitMiddleWare.ifPremiumThenProceed,
    asyncHandler(async (req, res, next) => {
        const pageInfo = {
            title: "Welcome to Mentally::주치의 큐레이팅 시스템"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };
 
        res.render("helpNeeded_user/helpNeeded_user_share", {pageInfo, accountInfo, layout: mainLayout_LoggedIn});

        return;
    }),
    loginMiddleWare.errorOccured
)

router.post(['/curate'],
    loginMiddleWare.ifLoggedInThenProceed,
    limitMiddleWare.ifPremiumThenProceed,
    asyncHandler(async (req, res, next) => {
        const user = await User.findById(req.session.user._id);

        if (user.posts.length < 1 || user.ai_chats.length < 1) {
            res.redirect("/helpNeeded/error");

            return;
        }

        const curate = await Curate.create({
            user: req.session.user._id,
            posts: user.posts,
            ai_chats: user.ai_chats,
        });

        req.session.user = await User.findByIdAndUpdate(req.session.user._id, {
            $push: {curates: curate._id}
        }, {
            new: true
        });

        res.redirect("/helpNeeded/curatePost/" + curate._id);

        return;
    }),
    loginMiddleWare.errorOccured
);

router.get(['/curatePost/:id'],
    loginMiddleWare.ifLoggedInThenProceed,
    limitMiddleWare.ifPremiumThenProceed,
    asyncHandler(async (req, res, next) => {
        const curate = await Curate.findById(req.params.id);
        const commentList = [];

        /* not to allow unauthorized users */
        if (curate.user != req.session.user._id) {
            res.redirect("/error");

            return;
        }

        let posts = await curate.populate('posts', 'title _id');
        posts = posts.posts;
        // console.log(posts);
        let ai_chats = await curate.populate('ai_chats', 'title _id');
        ai_chats = ai_chats.ai_chats;
        // console.log(ai_chats);

        let comments = await curate.populate('comments');
        comments = comments.comments;
        // console.log(comments);

        for (const comment of comments) {
            const doctor = await Doctor.findById(comment.doctor);
            commentList.push({doctor: doctor.name, doctorid: doctor._id, comment: comment.content, date: comment.date});
        }

        const pageInfo = {
            title: "Welcome to Mentally::큐레이팅"
        };
        const accountInfo = {
            id: req.session.user.id,
            _id: req.session.user._id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("helpNeeded_user/helpNeeded_user_shared",{
            pageInfo, accountInfo, curate, posts, ai_chats, commentList, layout: mainLayout_LoggedIn
        });

        return;
    }),
    loginMiddleWare.errorOccured
);

router.get(['/myCurate'],
    loginMiddleWare.ifLoggedInThenProceed,
    limitMiddleWare.ifPremiumThenProceed,
    asyncHandler(async (req, res, next) => {
        let curates = await User.findById(req.session.user._id).populate('curates');

        curates = curates.curates.sort((a, b) => {
            return new Date(b.date) - new Date(a.date);
        });

        const pageInfo = {
            title: "Welcome to Mentally::큐레이팅 리스트"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("helpNeeded_user/helpNeeded_user_lists",{
            pageInfo, accountInfo, curates, layout: mainLayout_LoggedIn
        });

        return;
    }),
    loginMiddleWare.errorOccured
);

router.get(['/error'],
    loginMiddleWare.ifLoggedInThenProceed,
    limitMiddleWare.ifPremiumThenProceed,
    asyncHandler(async (req, res, next) => {
        const pageInfo = {
            title: "Welcome to Mentally::큐레이팅 에러"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("helpNeeded_user/helpNeeded_user_error",{pageInfo, accountInfo, layout: mainLayout_LoggedIn});

        return;
    }),
    loginMiddleWare.errorOccured
);

module.exports = router;