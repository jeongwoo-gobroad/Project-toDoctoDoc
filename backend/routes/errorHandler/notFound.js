const returnResponse = require("../mapp/standardResponseJSON");

const notFoundHandler = (req, res, next) => {
    res.status(404).send(returnResponse(true, "404 not found", "-"));

    return;
};

module.exports = notFoundHandler; 