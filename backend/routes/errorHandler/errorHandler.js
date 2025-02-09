const returnResponse = require("../mapp/standardResponseJSON");

const errorHandler = (err, req, res, next) => {
    res.status(500).send(returnResponse(true, "Internal Server Error", err));

    return;
};

module.exports = errorHandler; 