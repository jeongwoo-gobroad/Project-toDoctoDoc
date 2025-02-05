require("dotenv").config;
const request = require("request");
const caching = require("./redisCaching");

/* radius는 m 단위이다. */
const returnListOfPsychiatry = (x, y, radius, page) => {
    const executor = async (resolve, reject) => {
        const kakaoMapOptions = {
            uri: encodeURI(`https://dapi.kakao.com/v2/local/search/keyword?query=정신건강의학과&x=${x}&y=${y}&radius=${radius}&page=${page}`),
            method: 'GET',
            json: true,
            headers: {
                Authorization: `KakaoAK ${process.env.KAKAO_REST_KEY}`
            },
        };

        let cached;

        if ((cached = await caching.getCache("DOCS:" + kakaoMapOptions.uri))) {
            console.log("returned cached documents");

            resolve(cached);
        }

        request.get(kakaoMapOptions, (err, result, body) => {
            if (!err) {
                caching.setCache("DOCS:" + kakaoMapOptions.uri, body.documents);
                resolve(body.documents);
            } else {
                reject(err);
            }
        });
    };

    return new Promise(executor);
}

module.exports = returnListOfPsychiatry;