const Redis = require("../config/redisObject");
const Post = require("../models/Post")
const removeSpacesAndHashes = require("../middleware/usefulFunctions").removeSpacesAndHashes;

const bubbleCollection = async () => {
    try {
        const allItems = await Post.find();
        let redis = new Redis();
        const tagCountBubbleMap = new Map();
        let maxTagCountVal = 0;
        let maxViewCountVal = 0;
        
        await redis.connect();

        tagCountBubbleMap.clear();

        for (const post of allItems) {
            const tagLine = removeSpacesAndHashes(post.tag);
            const tags = tagLine.split(",");

            for (const tag of tags) {
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
            }
        }

        // allItems.forEach((post) => {
        //     const tagLine = removeSpacesAndHashes(post.tag);
        //     const tags = tagLine.split(",");

        //     tags.forEach((tag) => {
        //         if (tag.length > 0) {
        //             if (tagCountBubbleMap.has(tag)) {
        //                 const context = tagCountBubbleMap.get(tag);
        //                 context.tagCount++;
        //                 context.viewCount += post.views;
        //                 tagCountBubbleMap.set(tag, context);
        //                 if (context.tagCount > maxTagCountVal) {
        //                     maxTagCountVal = context.tagCount;
        //                 }
        //                 if (context.viewCount > maxViewCountVal) {
        //                     maxViewCountVal = context.viewCount;
        //                 }
        //             } else {
        //                 tagCountBubbleMap.set(tag, {
        //                     tagCount: 1,
        //                     viewCount: post.views
        //                 });
        //             }
        //         }
        //     });
        // });

        // tagCountBubbleMap.forEach(async (value, key, map) => {
        //     await setHashValue("GRAPHBOARD:", key, {
        //         tagCount: value.tagCount / maxTagCountVal,
        //         viewCount: value.viewCount / maxViewCountVal
        //     });
        // });
        for (const [key, value] of tagCountBubbleMap) {
            await redis.setHashValue("GRAPHBOARD:", key, {
                tagCount: value.tagCount / maxTagCountVal,
                viewCount: value.viewCount / maxViewCountVal
            });
        }

        await redis.setCacheForever("GRAPHBOARD_MAX_VIEWCOUNT:", maxViewCountVal);
        await redis.setCacheForever("GRAPHBOARD_MAX_TAGCOUNT:", maxTagCountVal);

        redis.closeConnnection();

        redis = null;

        console.log("GraphBoard Initiailized");
    } catch (error) {
        console.error(error, "errorAtBubbleCollection");

        return;
    }
};

module.exports = {bubbleCollection};