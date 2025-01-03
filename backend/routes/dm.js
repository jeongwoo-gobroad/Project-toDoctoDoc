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

const User = mongoose.models.User || mongoose.model("User", UserSchema);
const Address = mongoose.model("Address", AddressSchema);
const Doctor = require("../models/Doctor");
const Admin = require("../models/Admin");
const Post = require("../models/Post");
const AIChat = require("../models/AIChat");
const Curate = require("../models/Curate");
const Chat = require("../models/Chat");

router.get(["/checkIfDMExists"],
    loginMiddleWare.ifLoggedInThenProceed,
    asyncHandler(async (req, res, next) => {
        const userid = req.query.userid;
        const doctorid = req.query.doctorid;

        const chat = await Chat.findOne({
            $and: [
                {
                    user: userid
                },
                {
                    doctor: doctorid
                }
            ]
        });

        if (chat && req.session.isDoctor) {
            res.redirect("/dm_doc/messages/" + chat._id);
        } else if (chat) {
            res.redirect("/dm/messages/" + chat._id);
        } else {
            const newChat = await Chat.create({ 
                user: userid,
                doctor: doctorid
            });
            await Doctor.findByIdAndUpdate(doctorid,{
                $push: {chats: newChat._id}
            });
            await User.findByIdAndUpdate(userid, {
                $push: {chats: newChat._id}
            });
            res.redirect("/dm/messages/" + newChat._id);
        }
    })
);
 
module.exports = router; 