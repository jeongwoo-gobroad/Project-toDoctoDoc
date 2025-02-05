const { setHashValue, setCache } = require("../middleware/redisCaching");
const Post = require("../models/Post")
const removeSpacesAndHashes = require("../middleware/usefulFunctions").removeSpacesAndHashes;

const bubbleCollection = async () => {
    try {
        const allItems = await Post.find();
        const tagCountBubbleMap = new Map();
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
            setHashValue("GRAPHBOARD:", key, {
                tagCount: value.tagCount / maxTagCountVal,
                viewCount: value.viewCount / maxViewCountVal
            });
        });

        setCache("GRAPHBOARD_MAX_VIEWCOUNT:", maxViewCountVal);
        setCache("GRAPHBOARD_MAX_TAGCOUNT:", maxTagCountVal);

        console.log("GraphBoard Initiailized");
    } catch (error) {
        console.error(error, "errorAtBubbleCollection");

        return;
    }
};

module.exports = {bubbleCollection};