const express = require("express");
const router = express.Router();

router.get(["/about"], 
    (req, res, next) => {
        res.status(200).json({
            error: false,
            result: "Good",
            content: {
                string: "Hello, world!"
            }
        })

        return;
    }
);

module.exports = router;