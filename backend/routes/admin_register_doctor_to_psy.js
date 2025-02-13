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

router.get(["/registerDoctorToPsy"], 
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    async (req, res, next) => {
        const accountInfo = {
            usernick: req.session.user.usernick,
        };
        const pageInfo = {
            title: "Welcome to Mentally::Admin Menu::Register Doctor to Psy"
        };
         
        try {
            const doctors = await Doctor.find();

            res.render("admin/admin_register_doctor_to_psy", {doctors, accountInfo, pageInfo, layout: mainLayout_Admin});

            return;
        } catch (error) {
            console.log(error);

            res.redirect("/admin");

            return;
        }
    }
);

router.put(["/registerDoctorToPsy"],
    loginMiddleWare.ifLoggedInThenProceed,
    loginMiddleWare.isAdminThenProceed,
    async (req, res, next) => {
        const {doctorId, psyId} = req.body;

        try {
            const psy = await Psychiatry.findById(psyId);

            await Doctor.findByIdAndUpdate(doctorId, {
                myPsyID: psyId,
                address: psy.address,
            });

            if (psy) {
                psy.doctors.push(doctorId);

                await psy.save();

                res.redirect("/admin/registerDoctorToPsy");

                return;
            }

            res.send("No Such psychiatry");

            return;
        } catch (error) {
            console.error(error);

            res.redirect("/admin");

            return;
        }
    }
);

module.exports = router;