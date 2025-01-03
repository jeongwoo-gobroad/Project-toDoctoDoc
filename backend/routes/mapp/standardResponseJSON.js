const returnResponse = (err, result, content) => {
    return {
        error: err,
        result: result,
        content: content
    }
};

module.exports = returnResponse;