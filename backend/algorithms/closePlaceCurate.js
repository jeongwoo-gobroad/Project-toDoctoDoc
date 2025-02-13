const axios = require("axios");
const Redis = require("../config/redisObject");

const closePsychiatryFinding = async (x, y, radius) => {
    const uri = encodeURI(`https://dapi.kakao.com/v2/local/search/keyword?query=정신건강의학과&x=${x}&y=${y}&radius=${radius}`);

    const kakaoMapOptions = {
        method: 'GET',
        headers: {
            Authorization: `KakaoAK ${process.env.KAKAO_REST_KEY}`
        },
    };

    let cached;

    try {   
        let redis = new Redis();
        await redis.connect();

        if ((cached = await redis.getCache("DOCS:" + uri))) {
            console.log("returned cached documents for closePsy");
    
            redis.closeConnnection();
            redis = null;

            return cached;
        }
    
        const body = await axios.get(uri, kakaoMapOptions);

        await redis.setCache("DOCS:" + uri, body.data.documents);

        redis.closeConnnection();
        redis = null;

        return body.data.documents;
    } catch (error) {
        console.error(error, "errorAtClosePsychiatryFinding");

        throw new Error(error);
    }
};

module.exports = closePsychiatryFinding;