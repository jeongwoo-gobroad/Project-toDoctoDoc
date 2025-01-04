const express = require('express');
const router = express.Router();

router.use('/', require("./mapp/main"));
router.use('/', require("./mapp/user/auth"));
router.use('/', require("./mapp/user/mainscreen"));
router.use('/aichat', require("./mapp/user/chatbot").router);
router.use('/', require("./mapp/user/graphboard"));
router.use('/doctor', require("./mapp/doctor/auth"));

module.exports = router;
