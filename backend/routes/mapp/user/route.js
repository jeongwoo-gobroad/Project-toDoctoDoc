const express = require('express');
const router = express.Router();

router.use('/curate', require("./files_v2/curating"));
router.use('/schedule', require("./files_v2/scheduleManagement"));
router.use('/cheering', require("./files_v2/cheering"));
router.use('/accountManagement', require("./files_v2/accountManagement"));

module.exports = router; 