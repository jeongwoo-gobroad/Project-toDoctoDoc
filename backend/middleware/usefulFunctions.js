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
 
module.exports = {getLastSegment, getQuote};