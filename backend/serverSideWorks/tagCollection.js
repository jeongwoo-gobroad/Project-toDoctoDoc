const interval = 5000;
const Post = require("../models/Post");
const asyncHandler = require("express-async-handler");
const removeSpacesAndHashes = require("../middleware/usefulFunctions").removeSpacesAndHashes;

const tagMap = new Map();
const tagGraph = [];

const tagCollection = async () => {
    const allItems = await Post.find();
    const tempMap = new Map();

    tagMap.clear();
    tagGraph.length = 0;

    allItems.forEach((post) => {
        const tagLine = removeSpacesAndHashes(post.tag);

        const tags = tagLine.split(",");

        tags.forEach((tag) => {
            if (tag.length > 0) {
                if (tagMap.has(tag)) {
                    let count = tagMap.get(tag);
                    count++;
                    tagMap.set(tag, count);
                } else {
                    tagMap.set(tag, 1);
                }
                tags.forEach((anotherTag) => {
                    if (tag != anotherTag && !tempMap.has(tag + anotherTag)) {
                        tagGraph.push([tag, anotherTag]);
                        tempMap.set(tag + anotherTag);
                        tempMap.set(anotherTag + tag);
                    }
                });
            }
        });
    });

    // console.log(tagGraph);
};

module.exports = {tagCollection, tagMap, tagGraph };