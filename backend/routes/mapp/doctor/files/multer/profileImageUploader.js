const Multer = require('multer');
const stream = require('streamifier');
const path = require('path');
const googleCloudStorage = require('../../../../../googleCloud/storage');

const storage = googleCloudStorage;

/* bucket 이름을 지정하면 된다. */
const bucket = storage.bucket('todoctodoc_profile_image');

const upload = (req) => {
    const myFileName = 'doctorProfileImage/' + Date.now() + "_" + req.userid + path.extname(req.file.originalname);
    const chunk = bucket.file(myFileName);
    const chunkStream = chunk.createWriteStream();

    req.myFileName = myFileName;

    // console.log(chunkStream); /* chunk, chunkStream 모두 관찰 해 봤는데, 업로드 URL을 뱉어내지는 않았다. */

    return new Promise((resolve, reject) => { // 콜백 함수 내에서 반환을 해야 하기 때문에 Promise를 반환하도록 설계한다.
        stream.createReadStream(req.file.buffer)
            .on('error', (error) => {
                return reject(error);
            })
            .pipe(chunkStream)
            .on('finish', (response) => {
                return resolve(response); /* 사실 response는 null 값이 나오는 것 같다. */
            });
    });
};

const multer = Multer({
    storage: Multer.memoryStorage(),
    limits: {fileSize: 5 * 1024 * 1024}
});

module.exports = {upload, multer};