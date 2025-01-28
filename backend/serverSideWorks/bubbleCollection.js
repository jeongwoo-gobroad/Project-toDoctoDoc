const Post = require("../models/Post")
const removeSpacesAndHashes = require("../middleware/usefulFunctions").removeSpacesAndHashes;

const tagCountBubbleMap = new Map();

const bubbleCollection = async () => {
    const allItems = await Post.find();
    let maxTagCountVal = 0;
    let maxViewCountVal = 0;
    
    tagCountBubbleMap.clear();

    allItems.forEach((post) => {
        const tagLine = removeSpacesAndHashes(post.tag);
        const tags = tagLine.split(",");

        tags.forEach((tag) => {
            if (tag.length > 0) {
                if (tagCountBubbleMap.has(tag)) {
                    const context = tagCountBubbleMap.get(tag);
                    context.tagCount++;
                    context.viewCount += post.views;
                    tagCountBubbleMap.set(tag, context);
                    if (context.tagCount > maxTagCountVal) {
                        maxTagCountVal = context.tagCount;
                    }
                    if (context.viewCount > maxViewCountVal) {
                        maxViewCountVal = context.viewCount;
                    }
                } else {
                    tagCountBubbleMap.set(tag, {
                        tagCount: 1,
                        viewCount: post.views
                    });
                }
            }
        });
    });

    tagCountBubbleMap.forEach((value, key, map) => {
        tagCountBubbleMap.set(key, {
            tagCount: value.tagCount / maxTagCountVal,
            viewCount: value.viewCount / maxViewCountVal
        });
    });
};

module.exports = {tagCountBubbleMap, bubbleCollection};