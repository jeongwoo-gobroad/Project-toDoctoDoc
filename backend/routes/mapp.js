const express = require('express');
const router = express.Router();

router.use('/', require("./mapp/main"));
router.use('/user', require("./mapp/user/auth"));
router.use('/user', require("./mapp/user/mainscreen"));

module.exports = router;