require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const mainLayout_Doctor = "../views/layouts/main_Doctor_LoggedIn";
const mainLayout_Admin = "../views/layouts/main_Admin_LoggedIn";
const asyncHandler = require("express-async-handler");
const bcrypt = require("bcrypt");
const openai = require("openai");
const UserSchema = require("../models/User");
const AddressSchema = require("../models/Address");
const mongoose = require("mongoose");
const loginMiddleWare = require("./checkLogin");
const limitMiddleWare = require("./checkLimit");

const User = mongoose.model("User", UserSchema);
const Address = mongoose.model("Address", AddressSchema);
const Doctor = require("../models/Doctor");
const Admin = require("../models/Admin");
const Post = require("../models/Post");
const AIChat = require("../models/AIChat");
const Curate = require("../models/Curate");
const Chat = require("../models/Chat");

router.get(["/list"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const doctor = await Doctor.findById(req.session.user._id).populate('chats');
        const chatList = [];

        for (const chat of doctor.chats) {
            const patientName = await User.findById(chat.user, 'usernick');
            chatList.push({
                _id: chat._id,
                user: patientName,
                date: chat.date
            });
        }

        const chats = chatList.sort(
            (a, b) => {
                new Date(b.date) - new Date(a.date);
            }
        );

        const pageInfo = {
            title: "Welcome to Mentally::DM 리스트"
        };
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("dm/dm_doctor_list", {pageInfo, accountInfo, chats, layout: mainLayout_Doctor});
    })
);

router.get(["/messages/:id"],
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isDoctorThenProceed,
    asyncHandler(async (req, res, next) => {
        const prevChats = await Chat.findById(req.params.id).populate('user doctor');

        /* Not to allow unauthorized users */
        if (prevChats.doctor._id != req.session.user._id) {
            res.redirect("/error");

            return;
        }

        const pageInfo = {
            title: "Welcome to Mentally::DM with Patient " + prevChats.user.usernick,
        };
        const prevChatList = JSON.stringify(prevChats.chatList);
        const accountInfo = {
            id: req.session.user.id,
            usernick: req.session.user.usernick,
            address: req.session.user.address,
            email: req.session.user.email,
        };

        res.render("dm/dm_doctor_dm", {pageInfo, accountInfo, prevChats, prevChatList, layout: mainLayout_Doctor});
    })
);

module.exports = router;