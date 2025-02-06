const googleCloudStorage = require("../../../../../googleCloud/storage");
const Psychiatry = require("../../../../../models/Psychiatry");

const storage = googleCloudStorage;

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