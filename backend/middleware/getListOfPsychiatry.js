const axios = require('axios');
const Redis = require('../config/redisObject');

/* radius는 m 단위이다. */
const returnListOfPsychiatry = async (x, y, radius, page) => {
    const uri = encodeURI(`https://dapi.kakao.com/v2/local/search/keyword?query=정신건강의학과&x=${x}&y=${y}&radius=${radius}&page=${page}`);

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
            console.log("returned cached documents");
    
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
        console.error(error, "errorAtReturnListOfPsychiatry");

        return null;
    }
}

module.exports = returnListOfPsychiatry;