const express = require('express');
const router = express.Router();

router.use('/', require("./mapp/main"));
router.use('/', require("./mapp/user/auth"));
router.use('/', require("./mapp/user/mainscreen"));
router.use('/aichat', require("./mapp/user/chatbot").router);
router.use('/', require("./mapp/user/graphboard"));
router.use('/doctor', require("./mapp/doctor/route"));
router.use('/curate', require("./mapp/user/curating"));
router.use('/careplus', require("./mapp/user/curating-pro"));
router.use('/careplus', require("./mapp/user/appointment"));
router.use('/careplus', require("./mapp/user/dm"));
router.use('/', require("./auth/token_refresh"));
router.use('/review', require("./mapp/user/review"));

module.exports = router;
