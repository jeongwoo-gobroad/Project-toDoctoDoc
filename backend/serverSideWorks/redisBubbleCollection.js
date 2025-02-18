const Redis = require("../config/redisObject");
const { removeSpacesAndHashes } = require("../middleware/usefulFunctions");

const tagCountRefreshWorksViaRedis = async (newTags) => {
    const tagLine = removeSpacesAndHashes(newTags);
    const tags = tagLine.split(",");
    let redis = new Redis();

    await redis.connect();

    const prev = await redis.getHashAll("GRAPHBOARD:");
    let maxTagCount = await redis.getCache("GRAPHBOARD_MAX_TAGCOUNT:");

    for (let [tag, obj] of prev) {
        obj.tagCount *= maxTagCount;
    }

    for (const tag of tags) {
        if (prev.has(tag)) {
            let val = prev.get(tag);
            val.tagCount++;
            
            if (val.tagCount > maxTagCount) {
                maxTagCount = val.tagCount;
            }

            prev.set(tag, val);
        } else {
            prev.set(tag, {
                tagCount: 1,
                viewCount: 0
            });
        }
    }

    for (let [tag, obj] of prev) {
        obj.tagCount /= maxTagCount;
        await redis.setHashValue("GRAPHBOARD:", tag, obj);
    }
    await redis.setCacheForever("GRAPHBOARD_MAX_TAGCOUNT:", maxTagCount);

    redis.closeConnnection();

    redis = null;

    // console.log(prev, "tagCountRefreshWorksViaRedis");

    return;
};

const tagCountMinusWorksViaRedis = async (prevTags) => {
    const tagLine = removeSpacesAndHashes(prevTags);
    const tags = tagLine.split(",");
    let redis = new Redis();

    await redis.connect();

    const prev = await redis.getHashAll("GRAPHBOARD:");
    let maxTagCount = 0;

    for (let [tag, obj] of prev) {
        obj.tagCount *= maxTagCount;
    }

    for (const tag of tags) {
        if (prev.has(tag)) {
            let val = prev.get(tag);
            val.tagCount--;
            
            if (val.tagCount > maxTagCount) {
                maxTagCount = val.tagCount;
            }

            prev.set(tag, val);
        }
        if (prev.get(tag).tagCount > maxTagCount) {
            maxTagCount = prev.get(tag).tagCount;
        }
    }

    for (let [tag, obj] of prev) {
        obj.tagCount /= maxTagCount;
        await redis.setHashValue("GRAPHBOARD:", tag, obj);
    }
    await redis.setCacheForever("GRAPHBOARD_MAX_TAGCOUNT:", maxTagCount);

    redis.closeConnnection();

    redis = null;

    // console.log(prev, "tagCountRefreshWorksViaRedis");

    return;
};

const viewCountRefreshWorksViaRedis = async (currentTags) => {
    const tagLine = removeSpacesAndHashes(currentTags);
    const tags = tagLine.split(",");
    let redis = new Redis();

    await redis.connect();

    const prev = await redis.getHashAll("GRAPHBOARD:");
    let maxViewCount = await redis.getCache("GRAPHBOARD_MAX_VIEWCOUNT:");

    for (let [tag, obj] of prev) {
        obj.viewCount *= maxViewCount;
    }

    for (const tag of tags) {
        if (prev.has(tag)) {
            let val = prev.get(tag);
            val.viewCount++;
            
            if (val.viewCount > maxViewCount) {
                maxViewCount = val.viewCount;
            }

            prev.set(tag, val);
        }
    }

    for (let [tag, obj] of prev) {
        obj.viewCount /= maxViewCount;
        await redis.setHashValue("GRAPHBOARD:", tag, obj);
    }
    await redis.setCacheForever("GRAPHBOARD_MAX_VIEWCOUNT:", maxViewCount);

    redis.closeConnnection();

    redis = null;

    // console.log(prev, "viewCountRefreshWorksViaRedis");

    return;
};

module.exports = {tagCountRefreshWorksViaRedis, tagCountMinusWorksViaRedis, viewCountRefreshWorksViaRedis};