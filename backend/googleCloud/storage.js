const { Storage } = require("@google-cloud/storage");

const googleCloudStorage = new Storage({
    /* keyFile이 아닌 keyFilename으로 지정해야 정상 동작 */
    keyFilename: './_secrets/googlecloud/todoctodoc-googlecloud-storagekey.json', 
    projectId: 'todoctodoc-c8702'
});

module.exports = googleCloudStorage;