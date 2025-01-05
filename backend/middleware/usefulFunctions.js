function getLastSegment(url) {
    const match = url.match(/\/([^\/]+)\/?$/);
    return match ? match[1] : null;
}

const getQuote = (sentence) => {
    const regex = /['"](.*?)['"]/g;
    const titles = sentence.match(regex).map(match => match.replace(/['"]/g, ''));

    return titles[0];
}
 
module.exports = {getLastSegment, getQuote};