const express = require('express');
const router = express.Router();

router.use('/', require("./files/auth"));
router.use('/', require("./files/mainscreen"));
router.use('/curate', require("./files/curating"));
router.use('/dm', require("./files/dm"));
router.use('/review', require("./files/review"));

module.exports = router; 