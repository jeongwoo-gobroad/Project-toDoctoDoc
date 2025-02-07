const express = require('express');
const router = express.Router();

router.use('/curate', require("./files_v2/curating"));

module.exports = router; 