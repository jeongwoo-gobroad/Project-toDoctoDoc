function getLastSegment(url) {
    const match = url.match(/\/([^\/]+)\/?$/);
    return match ? match[1] : null;
}

const getQuote = (sentence) => {
    const regex = /"([^"]*)"/; // /"([^"]*)"/ // 아스키코드만 걸러냄에 주의!!
    // const titles = [];
    // let match;

    // console.log(sentence);
    // console.log(sentence.match(regex));
    // console.log(sentence.match(regex)[1]);
    // console.log(titles);

    return sentence.match(regex)[1];
}

const removeSpacesAndHashes = (input) => { 
    if (input && input.length > 0) {
        return input.replace(/[\s#]/g, '');
    } 

    return "";
};

module.exports = {getLastSegment, getQuote, removeSpacesAndHashes};