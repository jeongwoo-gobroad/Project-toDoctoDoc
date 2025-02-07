const express = require('express');
const router = express.Router();

router.use('/curate', require("./files/curating"));

module.exports = router; 