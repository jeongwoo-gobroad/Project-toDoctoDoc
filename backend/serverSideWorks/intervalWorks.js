const { bubbleCollection } = require("./bubbleCollection");
const { tagCollection } = require("./tagCollection")

const intervalWorks = async () => {
    try {
        tagCollection();
        bubbleCollection();

        return;
    } catch (error) {
        console.error(error, "errorAtIntervalWorks");

        return;
    }
};

module.exports = intervalWorks;