const Multer = require('multer');
const stream = require('streamifier');
const { Storage } = require("@google-cloud/storage");
const path = require('path');
const returnResponse = require('../../../standardResponseJSON');

const storage = new Storage({
    /* keyFile이 아닌 keyFilename으로 지정해야 정상 동작 */
    keyFilename: './todoctodoc-googlecloud-storagekey.json', 
    projectId: 'todoctodoc-c8702'
});

/* bucket 이름을 지정하면 된다. */
const bucket = storage.bucket('todoctodoc_profile_image');

const upload = (req, res, next) => {
    let count = 0;
    req.myFiles = [];

    for (const file of req.files) {
        const myFileName = 'psyProfileImage/' + Date.now() + "_" + req.psyId + "_" + count + path.extname(file.originalname);

        const chunk = bucket.file(myFileName);
        const chunkStream = chunk.createWriteStream({
            metadata: {contentType: file.mimetype}
        });
        stream.createReadStream(file.buffer)
            .on('error', (error) => {
                res.status(200).json(returnResponse(true, "errorAtPsyProfileImageUploading", "-"));

                console.error(error, "errorAtPsyProfileImageUploader");

                next(error);
            })
            .pipe(chunkStream)
            .on('finish', (response) => {
                console.log("img:", myFileName, "uploaded");
            });
        
        req.myFiles.push(myFileName);
        count++;
    }

    next();
};

const multer = Multer({
    storage: Multer.memoryStorage(),
    limits: {
        files: 10,
        fileSize: 5 * 1024 * 1024
    }
});

module.exports = {upload, multer};