function getLastSegment(url) {
    const match = url.match(/\/([^\/]+)\/?$/);
    return match ? match[1] : null;
}

const getQuote = (sentence) => {
    const regex = /"([^"]*)"/g;
    const titles = [];
    let match;

    while ((match = regex.exec(sentence)) !== null) {
        titles.push(match[1]);
    }

    return titles[0];
}
 
module.exports = {getLastSegment, getQuote};