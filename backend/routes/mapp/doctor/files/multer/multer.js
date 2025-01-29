const multer = require('multer');
const multerGoogleStorage = require('multer-google-storage');

const upload = multer({
    storage: multerGoogleStorage.storageEngine({
        bucket: 'todoctodoc_profile_image',
        projectId: 'todoctodoc-c8702',
        keyFilename: "./todoctodoc-googlecloud-storagekey.json",
        filename: (req, file, cb) => {
            cb(null, `doctorProfileImage/${Date.now()}_${req.userid}`);
        }
    }),
    limits: {fileSize: 5*1024*1024},
    onError: (error, next) => {
        console.error(error, "errorAtMulterUploadFunction");
        next(error);
    },
});

module.exports = upload;