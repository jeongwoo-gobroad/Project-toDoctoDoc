const axios = require('axios');

const returnLongLatOfAddress = async (address) => {
    const uri = encodeURI(`https://dapi.kakao.com/v2/local/search/address?query=${address}`);

    const kakaoMapOptions = {
        method: 'GET',
        headers: {
            Authorization: `KakaoAK ${process.env.KAKAO_REST_KEY}`
        }
    };

    try {
        const body = await axios.get(uri, kakaoMapOptions);

        return {long: body.data.documents[0].address.x, lat: body.data.documents[0].address.y};
    } catch (error) {
        console.error(error, "errorAtReturnLongLatOfAddress");

        return null;
    }
};

module.exports = returnLongLatOfAddress;