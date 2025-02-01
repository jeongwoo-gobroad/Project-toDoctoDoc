const express = require('express');
const router = express.Router();

router.use('/user', require("./user/restfulOperation"));
router.use('/doctor', require("./doctor/restfulOperation"));

module.exports = router; 