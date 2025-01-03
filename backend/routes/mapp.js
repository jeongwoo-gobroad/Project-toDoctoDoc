const express = require('express');
const router = express.Router();

router.use('/', require("./mapp/main"));
router.use('/', require("./mapp/user/auth"));
router.use('/', require("./mapp/user/mainscreen"));
router.use('/', require("./mapp/user/chatbot"));
router.use('/', require("./mapp/user/graphboard"));

module.exports = router;