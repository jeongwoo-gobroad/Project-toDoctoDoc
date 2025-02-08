const express = require('express');
const router = express.Router();

router.use('/curate', require("./files_v2/curating"));
router.use('/schedule', require("./files_v2/scheduleManagement"));

module.exports = router; 