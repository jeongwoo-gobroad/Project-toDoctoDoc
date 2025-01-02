require("dotenv").config();
const request = require("request");

const returnLongLatOfAddress = (address) => {
    const executor = (resolve, reject) => {
        const kakaoMapOptions = {
            uri: encodeURI(`https://dapi.kakao.com/v2/local/search/address?query=${address}`),
            method: 'GET',
            json: true,
            headers: {
                Authorization: `KakaoAK ${process.env.KAKAO_REST_KEY}`
            }
        };
        request.get(kakaoMapOptions, (err, result, body) => {
            if (!err) {
                resolve({long: body.documents[0].address.x, lat: body.documents[0].address.y});
            } else {
                reject(err);
            }
        });
    };

    return new Promise(executor);
};

module.exports = returnLongLatOfAddress;