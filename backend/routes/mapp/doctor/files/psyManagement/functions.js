const Psychiatry = require("../../../../../models/Psychiatry");
const { Storage } = require("@google-cloud/storage");

const storage = new Storage({
    /* keyFile이 아닌 keyFilename으로 지정해야 정상 동작 */
    keyFilename: './todoctodoc-googlecloud-storagekey.json', 
    projectId: 'todoctodoc-c8702'
});

const doesOwnPsy = async (psyId, doctorId) => {
    try {
        const psy = await Psychiatry.findById(psyId);

        if (psy.doctors.toString().includes(doctorId)) {
            return true;
        }

        return false;
    } catch (error) {
        console.error(error, "errorAtDoesOwnPsy");

        return false;
    }
};

const findByFileNameAndDelete = async (psyId, fileName) => {
    try {
        const wholeFileName = process.env.GCP_DOCTOR_URI + 'psyProfileImage/' + fileName;

        await Psychiatry.findByIdAndUpdate(psyId, {
            $pull: {psyProfileImage: wholeFileName}
        });

        await storage.bucket('todoctodoc_profile_image').file('psyProfileImage/' + fileName).delete();

        return;
    } catch (error) {
        console.error(error, "errorAtFindByFileNameAndDelete");

        return;
    }
};

module.exports = {doesOwnPsy, findByFileNameAndDelete};