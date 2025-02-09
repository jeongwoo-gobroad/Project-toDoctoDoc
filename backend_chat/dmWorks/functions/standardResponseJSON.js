const returnResponse = (err, result, content) => {
    return JSON.stringify({
        error: err,
        result: result,
        content: content
    });
};

module.exports = returnResponse;