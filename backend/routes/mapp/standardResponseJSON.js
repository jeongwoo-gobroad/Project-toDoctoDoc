const returnResponse = (err, result, content) => {
    return {
        error: err,
        result: result,
        content: JSON.stringify(content)
    }
};

module.exports = returnResponse;