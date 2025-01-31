const { bubbleCollection } = require("./bubbleCollection");
const { tagCollection } = require("./tagCollection")

const tagRefreshWorks =  (args) => {
    console.log("Event Driven:: Post Tag Updating");
    try {
        bubbleCollection();
        // tagCollection();
    } catch (error) {
        console.error(error, "errorAtPostTagUpdatingEvent");
    }
};

module.exports = tagRefreshWorks;