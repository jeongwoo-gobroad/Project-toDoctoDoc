require("dotenv").config;
const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, getTokenInformation } = require("../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn } = require("../checkingMiddleWare");
const { route } = require("../main");
const returnLongLatOfAddress = require("../../../middleware/getcoordinate");
const router = express.Router();

const User = mongoose.model("User", UserSchema);
const Chat = require("../../../models/Chat");
const AIChat = require("../../../models/AIChat");

router.get(["/around"],
    checkIfLoggedIn,
    async (req, res, next) => {
        const user = await getTokenInformation(req, res);

        
    }
);

module.exports = router;