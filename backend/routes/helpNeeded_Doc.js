require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const mainLayout_Doctor = "../views/layouts/main_Doctor_LoggedIn";
const asyncHandler = require("express-async-handler");
const bcrypt = require("bcrypt");
const UserSchema = require("../models/User");
const AddressSchema = require("../models/Address");
const mongoose = require("mongoose");
const loginMiddleWare = require("./checkLogin");
const request = require("request");

const User = mongoose.models.User || mongoose.model("User", UserSchema);
const Address = mongoose.model("Address", AddressSchema);
const Doctor = require("../models/Doctor");
const Curate = require("../models/Curate");
const Comment = require("../models/Comment");

router.get(["/"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const accountInfo = req.session.user;
        const pageInfo = {
            title: "Welcome to Mentally::의사용 메뉴"
        };

        res.render("doctor/helpNeeded_Doctor_main", {accountInfo, pageInfo, layout: mainLayout_Doctor});
    }),
    loginMiddleWare.errorOccured
);

router.get(["/curate"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const arnd = parseFloat(req.query.km);
        const userLong = req.session.user.address.longitude;
        const userLat  = req.session.user.address.latitude;
        const curate = [];

        const nearPatients = await User.find({
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
                }
            ]
        });
        
        for (const patient of nearPatients) {
            for (const id of patient.curates) {
                curate.push(await Curate.findById(id));
            }
        }

        const curates = curate.sort((a, b) => {
            return new Date(b.date) - new Date(a.date);
        })

        const accountInfo = req.session.user;
        const pageInfo = {
            title: "Welcome to Mentally::의사용 큐레이팅 서비스"
        };

        res.render("doctor/helpNeeded_Doctor_around", {accountInfo, pageInfo, curates, arnd, layout: mainLayout_Doctor});
    }),
    loginMiddleWare.errorOccured
);

router.get(["/view/:id"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const curatePost = await Curate.findById(req.params.id);
        const user = await curatePost.populate('user posts ai_chats comments');

        const usernick = user.user.usernick;
        const posts = user.posts;
        const ai_chats = user.ai_chats;
        const date = curatePost.date;
        const comments = user.comments;
        const commentList = [];
 
        for (const comment of comments) {
            const doctor = await Comment.findById(comment._id).populate('doctor');
            commentList.push({
                doctorid: doctor.doctor._id,
                doctor: doctor.doctor.name,
                date: comment.date,
                content: comment.content,
                commentid: comment._id
            });
        }

        const accountInfo = req.session.user;
        const postInfo = req.params.id;
        const pageInfo = {
            title: "Welcome to Mentally::의사용 큐레이팅 서비스"
        };

        res.render("doctor/helpNeeded_Doctor_view", {
            accountInfo, pageInfo, usernick, posts, ai_chats, commentList, date, postInfo, layout: mainLayout_Doctor
        });
    }),
);

router.post(["/comment/:id"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const comment = await Comment.create({
            doctor: req.session.user._id,
            content: req.body.comment,
        });

        await Curate.findByIdAndUpdate(req.params.id, {
            $push: {comments: comment}
        });

        res.redirect("/helpNeeded_doc/view/" + req.params.id);

        return;
    })
);

router.get(["/comment/edit/:id"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const comment = await Comment.findById(req.params.id);
        const post = req.query.postid;

        if (comment.doctor != req.session.user._id) {
            res.redirect("/error");
        }

        const accountInfo = req.session.user;
        const pageInfo = {
            title: "Welcome to Mentally::의사용 큐레이팅 서비스"
        };

        res.render("doctor/helpNeeded_Doctor_edit", {
            accountInfo, pageInfo, comment, post, layout: mainLayout_Doctor
        });
    })
);

router.put(["/comment/edit/:id"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const comment = await Comment.findById(req.params.id);

        if (comment.doctor != req.session.user._id) {
            res.redirect("/error");
        }

        await Comment.findByIdAndUpdate(req.params.id, {
            content: req.body.comment,
            date: Date.now()
        });

        res.redirect("/helpNeeded_doc/view/" + req.query.postid);
    })
);

router.delete(["/comment/delete/:id"],
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const comment = await Comment.findById(req.params.id);
        await Curate.findByIdAndUpdate(req.query.postid, {
            $pull: {comments: req.params.id}
        });

        if (comment.doctor != req.session.user._id) {
            res.redirect("/error");
        }

        await Comment.findByIdAndDelete(req.params.id);

        res.redirect("/helpNeeded_doc/view/" + req.query.postid);
    })
);

module.exports = router;