const express = require('express');
const router = express.Router();

router.use('/curate', require("./files/curating"));
router.use('/schedule', require("./files/scheduleManagement"));

module.exports = router; 