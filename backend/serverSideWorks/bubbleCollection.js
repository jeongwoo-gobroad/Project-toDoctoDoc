const mongoose = require("mongoose");
const Post = require("../models/Post")
const { removeSpacesAndHashes } = require("../middleware/usefulFunctions");

const bubbleMap = new Map();

const bubbleCollection = async () => {
    const allItems = await Post.find();
    let maxVal = 0;
    
    bubbleMap.clear();

    allItems.forEach((post) => {
        const tagLine = removeSpacesAndHashes(post.tag);
        const tags = tagLine.split(",");

        tags.forEach((tag) => {
            if (tag.length > 0) {
                if (bubbleMap.has(tag)) {
                    let count = bubbleMap.get(tag);
                    count++;
                    bubbleMap.set(tag, count);
                    if (count > maxVal) {
                        maxVal = count;
                    }
                }
            }
        });
    });

    bubbleMap.forEach((bubble) => {
        let count = bubble;

        console.log(count / maxVal);
    });
};

module.exports = {bubbleMap, bubbleCollection};