require("dotenv").config;
const request = require("request");

/* radius는 m 단위이다. */
const returnListOfPsychiatry = (x, y, radius, page) => {
    const executor = (resolve, reject) => {
        const kakaoMapOptions = {
            uri: encodeURI(`https://dapi.kakao.com/v2/local/search/keyword?query=정신건강의학과&x=${x}&y=${y}&radius=${radius}&page=${page}`),
            method: 'GET',
            json: true,
            headers: {
                Authorization: `KakaoAK ${process.env.KAKAO_REST_KEY}`
            },
        };

        request.get(kakaoMapOptions, (err, result, body) => {
            if (!err) {
                resolve(body.documents);
            } else {
                reject(err);
            }
        });
    };

    return new Promise(executor);
}

module.exports = returnListOfPsychiatry;