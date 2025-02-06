const Doctor = require("../../../../../models/Doctor");
const { getTokenInformation } = require("../../../../auth/jwt");
const returnResponse = require("../../../standardResponseJSON");
const googleCloudStorage = require("../../../../../googleCloud/storage");

const storage = googleCloudStorage;

const generationMatchPrecondition = 0;

const deleteOptions = {
    ifGenerationMatch: generationMatchPrecondition,
};

const deletePreviousImage = async (req, res, next) => {
    const user = await getTokenInformation(req, res);

    try {
        const doctor = await Doctor.findById(user.userid);

        if (doctor.myProfileImage.length > 0) {
            const fileName = doctor.myProfileImage.split('/')[5];

            await storage.bucket('todoctodoc_profile_image').file('doctorProfileImage/' + fileName).delete();

            doctor.myProfileImage = "";

            await doctor.save();
        }

        next();

        return;
    } catch (error) {
        console.error(error, "errorAtDeletePreviousImage");

        res.status(405).json(returnResponse(true, "errorAtDeletePreviousImage", "-"));

        return;
    }
};

module.exports = deletePreviousImage;