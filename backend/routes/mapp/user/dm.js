const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const UserSchema = require("../../../models/User");
const returnResponse = require("../standardResponseJSON");
const jwt = require("jsonwebtoken");
const { generateToken, generateRefreshToken } = require("../../auth/jwt");
const { checkIfLoggedIn, checkIfNotLoggedIn } = require("../checkingMiddleWare");
const returnLongLatOfAddress = require("../../../middleware/getcoordinate");
const router = express.Router();
const Doctor = require("../../../models/Doctor");
const User = mongoose.model("User", UserSchema);

module.exports = router;