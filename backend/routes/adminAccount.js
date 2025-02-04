require("dotenv").config();
const express = require("express");
const router = express.Router();
const mainLayout = "../views/layouts/main";
const mainLayout_LoggedIn = "../views/layouts/main_LoggedIn";
const mainLayout_Admin = "../views/layouts/main_Admin_LoggedIn";
const asyncHandler = require("express-async-handler");
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

router.get(["/"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    asyncHandler(async (req, res) => {
        const accountInfo = {
            usernick: req.session.user.usernick,
        };
        const pageInfo = {
            title: "Welcome to Mentally::Admin Menu"
        };

        res.render("admin/admin_home", {accountInfo, pageInfo, layout: mainLayout_Admin});
    })
);

router.get(["/doctorVerification"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    asyncHandler(async (req, res) => {
        const doctorInfo = await Doctor.find();

        const accountInfo = {
            usernick: req.session.user.usernick,
        };
        const pageInfo = {
            title: "Welcome to Mentally::Admin Menu::Doctor Verification"
        };

        res.render("admin/admin_doctor_verify", {doctorInfo, accountInfo, pageInfo, layout: mainLayout_Admin});
    })
);

router.patch(["/doctorVerification"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    asyncHandler(async (req, res) => {
        const {doctorID} = req.body;

        try {
            await Doctor.findByIdAndUpdate(doctorID, {
                isVerified: true
            });
        } catch (error) {
            console.log(error);

            res.redirect("/admin");

            return;
        }

        res.redirect("/admin/doctorVerification");
    })
);

router.get(["/login"], 
    //loginMiddleWare.isAdminThenProceed,
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::Admin Login"
        };

        res.render("admin/admin_login", {pageInfo, layout: mainLayout});
    })
);

router.post(["/login"], 
    loginMiddleWare.ifNotLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const {username, password} = req.body;
        
        try {
            const admin = await Admin.findOne({id: username});

            if (admin && admin.isVerified && await bcrypt.compare(password, admin.password)) {
                req.session.user = admin;
                req.session.isAdmin = true;

                res.cookie("token", generateToken_web({
                    userid: admin._id,
                    isPremium: false,
                    isDoctor: false,
                    isAdmin: true
                }), {maxAge: 900000});
                const refresh = generateRefreshToken_web();
                res.cookie("refreshToken", refresh, {maxAge: 10800000});

                await Admin.findByIdAndUpdate(admin._id, {
                    refreshToken: refresh
                });


                res.redirect("/admin");

                return;
            } else if (admin && !admin.isVerified) {
                res.redirect("/admin/register/pending");

                return;
            } else {
                res.redirect("/admin/login");

                return;
            }
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

router.get(["/register"], 
    loginMiddleWare.ifNotLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::Admin Register"
        };
    
        res.render("admin/admin_register", {pageInfo, layout: mainLayout});
    })
);

router.get(["/register/pending"], 
    loginMiddleWare.ifNotLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const pageInfo = {
            title: "Welcome to Mentally::Admin Register Pending"
        };
    
        res.render("admin/admin_register_pending", {pageInfo, layout: mainLayout});
    })
);

router.post(["/register"], 
    loginMiddleWare.ifNotLoggedInThenProceed,
    asyncHandler(async (req, res) => {
        const {
            id, password, password2, usernick, email
        } = req.body;

        const hashedPassword = await bcrypt.hash(password, 10);

        if (password != password2 || await Admin.findOne({id: id})) {
            res.redirect("/error");

            return;
        }

        try {
            const admin = await Admin.create({
                id: id,
                password: hashedPassword,
                usernick: usernick,
                email: email,
                isVerified: false,
            });

            res.redirect("/admin/register/pending");

            return;
        } catch (error) {
            console.log(error);

            res.redirect("/error");

            return;
        }
    })
);

router.get(["/posts"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    asyncHandler(async (req, res) => {
        const posts = await Post.find();

        const accountInfo = {
            usernick: req.session.user.usernick,
        };
        const pageInfo = {
            title: "Welcome to Mentally::Admin Menu::Doctor Verification"
        };

        res.render("admin/admin_posts_deletion", {posts, accountInfo, pageInfo, layout: mainLayout_Admin});
    })
);

router.delete(["/posts"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    asyncHandler(async (req, res) => {
        const {postID} = req.body;

        try {
            const user = await Post.findById(postID).user;

            await Post.findByIdAndDelete(postID);

            await User.findByIdAndUpdate(user, {
                $pull: {posts: postID}
            });
        } catch (error) {
            console.log(error);

            res.redirect("/admin");

            return;
        }

        res.redirect("/admin/posts");
    })
);

router.get(["/psyList"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    async (req, res, next) => {
        try {
            const prem = await Psychiatry.find();

            const accountInfo = {
                usernick: req.session.user.usernick,
            };
            const pageInfo = {
                title: "Welcome to Mentally::Admin Menu::Psy List."
            };
    
            res.render("admin/admin_psy_list", {prem, accountInfo, pageInfo, layout: mainLayout_Admin});

            return;
        } catch (error) {
            console.error(error);

            res.redirect("/error");

            return;
        }
    }
);

router.post(["/psyList"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    async (req, res, next) => {
        const { name, place_id, postcode, address, detailAddress, extraAddress, phone} = req.body;
        const { long, lat } = await returnLongLatOfAddress(address);

        try {
            await Psychiatry.create({
                name: name,
                place_id: place_id,
                address: {
                    postcode: postcode,
                    address: address,
                    detailAddress: detailAddress,
                    extraAddress: extraAddress,
                    longitude: long,
                    latitude: lat,
                },
                phone: phone,
            })

            res.redirect("/admin/psyList");
        } catch (error) {
            console.error(error);

            res.redirect("/error");

            return;
        }
    }
);

router.delete(["/psyList/:id"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    async (req, res, next) => {
        try {
            await Psychiatry.findByIdAndDelete(req.params.id);

            res.redirect("/admin/psyList");
        } catch (error) {
            console.error(error);

            res.redirect("/error");

            return;
        }
    }
);

router.patch(["/psyList/:id"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    async (req, res, next) => {
        const { name, place_id, postcode, address, detailAddress, extraAddress, phone } = req.body;
        const { long, lat } = await returnLongLatOfAddress(address);

        try {
            await Psychiatry.findByIdAndUpdate(req.params.id, {
                name: name,
                place_id: place_id,
                address: {
                    postcode: postcode,
                    address: address,
                    detailAddress: detailAddress,
                    extraAddress: extraAddress,
                    longitude: long,
                    latitude: lat,
                },
                phone: phone,
                updatedAt: Date.now(),
            })

            res.redirect("/admin/psyList");
        } catch (error) {
            console.error(error);

            res.redirect("/error");

            return;
        }
    }
);

module.exports = router;