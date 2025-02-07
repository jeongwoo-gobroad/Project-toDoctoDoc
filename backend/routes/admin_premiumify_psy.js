require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const mainLayout_Admin = "../views/layouts/main_Admin_LoggedIn";
const bcrypt = require("bcrypt");
const UserSchema = require("../models/User");
const AddressSchema = require("../models/Address");
const mongoose = require("mongoose");
const loginMiddleWare = require("./checkLogin");

const User = mongoose.models.User || mongoose.model("User", UserSchema);
const Address = mongoose.model("Address", AddressSchema);
const Doctor = require("../models/Doctor");
const Admin = require("../models/Admin");
const Post = require("../models/Post");
const { generateToken_web, generateRefreshToken_web } = require("./web_auth/jwt_web");
const returnLongLatOfAddress = require("../middleware/getcoordinate");
const Psychiatry = require("../models/Psychiatry");

router.get(["/premiumifyPsy"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    async (req, res) => {
        const accountInfo = {
            usernick: req.session.user.usernick,
        };
        const pageInfo = {
            title: "Welcome to Mentally::Admin Menu::Premiumify Psy"
        };
         
        try {
            const psys = await Psychiatry.find();

            res.render("admin/admin_premiumify_psy", {psys, accountInfo, pageInfo, layout: mainLayout_Admin});

            return;
        } catch (error) {
            console.log(error);

            res.redirect("/admin");

            return;
        }
    }
);

router.patch(["/premiumifyPsy"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    async (req, res) => {
        const {psyId} = req.body;

        try {
            await Psychiatry.findByIdAndUpdate(psyId, {
                isPremiumPsy: true,
                updatedAt: Date.now(),
            });

            res.redirect(["/admin/premiumifyPsy"]);

            return;
        } catch (error) {
            console.log(error);

            res.redirect("/admin");

            return;
        }
    }
);

router.delete(["/premiumifyPsy"],
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    async (req, res, next) => {
        const {psyId} = req.body;

        try {
            await Psychiatry.findByIdAndUpdate(psyId, {
                isPremiumPsy: false,
                updatedAt: Date.now(),
            });

            res.redirect(["/admin/premiumifyPsy"]);

            return;
        } catch (error) {
            console.log(error);

            res.redirect("/admin");

            return;
        }
    }
);

module.exports = router;