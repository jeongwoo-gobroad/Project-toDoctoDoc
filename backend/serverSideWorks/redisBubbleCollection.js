const { getHashAll, getCache, setHashValue, setCacheForever } = require("../middleware/redisCaching");
const { removeSpacesAndHashes } = require("../middleware/usefulFunctions");

const tagCountRefreshWorksViaRedis = async (newTags) => {
    const tagLine = removeSpacesAndHashes(newTags);
    const tags = tagLine.split(",");

    const prev = await getHashAll("GRAPHBOARD:");
    let maxTagCount = await getCache("GRAPHBOARD_MAX_TAGCOUNT:");

    for (let [tag, obj] of prev) {
        obj.tagCount *= maxTagCount;
    }

    for (const tag of tags) {
        if (prev.has(tag)) {
            const val = prev.get(tag);
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
        setHashValue("GRAPHBOARD:", tag, obj);
    }
    setCacheForever("GRAPHBOARD_MAX_TAGCOUNT:", maxTagCount);

    // console.log(prev, "tagCountRefreshWorksViaRedis");

    return;
};

const viewCountRefreshWorksViaRedis = async (currentTags) => {
    const tagLine = removeSpacesAndHashes(currentTags);
    const tags = tagLine.split(",");

    const prev = await getHashAll("GRAPHBOARD:");
    let maxViewCount = await getCache("GRAPHBOARD_MAX_VIEWCOUNT:");

    for (let [tag, obj] of prev) {
        obj.viewCount *= maxViewCount;
    }

    for (const tag of tags) {
        if (prev.has(tag)) {
            const val = prev.get(tag);
            val.viewCount++;
            
            if (val.viewCount > maxViewCount) {
                maxViewCount = val.viewCount;
            }

            prev.set(tag, val);
        }
    }

    for (let [tag, obj] of prev) {
        obj.viewCount /= maxViewCount;
        setHashValue("GRAPHBOARD:", tag, obj);
    }
    setCacheForever("GRAPHBOARD_MAX_VIEWCOUNT:", maxViewCount);

    // console.log(prev, "viewCountRefreshWorksViaRedis");

    return;
};

module.exports = {tagCountRefreshWorksViaRedis, viewCountRefreshWorksViaRedis};