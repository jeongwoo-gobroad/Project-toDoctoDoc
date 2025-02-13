const Doctor = require("../models/Doctor");
const moment = require("moment");
const closePsychiatryFinding = require("./closePlaceCurate");
const { getNearestDateInMomentType, diffAsMinutes } = require("./closeTimeCurate");

const returnAroundDoctorList = async (patientLong, patientLat, radius) => {
    try {
        const longConstant = 1 / 111.19;
        const latConstant = 1 / (6371 * 1 * Math.PI / 180 * Math.cos(parseFloat(patientLat) * Math.PI / 180));
        const newLong = parseFloat(patientLong);
        const newLat = parseFloat(patientLat);
        const newRadius = parseFloat(radius);

        const doctors = await Doctor.find({
            $and: [
                {
                    "address.longitude": 
                    {
                        $gte: newLong - newRadius * longConstant,
                        $lte: newLong + newRadius * longConstant
                    }
                },
                {
                    "address.latitude": 
                    {
                        $gte: newLat - newRadius * latConstant, 
                        $lte: newLat + newRadius * latConstant
                    }
                }
            ]
        }, 'name myProfileImage').populate('myPsyID', 'name isPremiumPsy place_id address stars times').populate('schedule', 'availableTime minimalAppointmentTime');

        const psys = await closePsychiatryFinding(patientLong, patientLat, radius);
        const psyMap = new Map();
        const starMap = new Map();
        let longestDistance = 0;
        let longestTime = 0;

        for (const psy of psys) {
            psyMap.set(psy.id, psy.distance);

            if (psy.distance > longestDistance) {
                longestDistance = psy.distance;
            }
        }

        for (const doctor of doctors) {
            if (psyMap.has(doctor.myPsyID.place_id)) {
                doctor.distanceScore = longestDistance / psyMap.get(doctor.myPsyID.place_id);
            } else {
                doctor.distanceScore = 0;
            }

            doctor.starScore = doctor.myPsyID.stars / 5;

            if (doctor.schedule) {
                doctor.leastTime = await getNearestDateInMomentType(doctor.schedule.availableTime, doctor._id, doctor.schedule.minimalAppointmentTime);
                if (doctor.leastTime && diffAsMinutes(moment(), doctor.leastTime) > longestTime) {
                    longestTime = doctor.leastTime;
                }
            } else {
                doctor.leastTime = "2099-12-31T23:59:59.500+00:00"
            }
        }

        for (const doctor of doctors) {
            doctor.timeScore = longestTime / diffAsMinutes(moment(), doctor.leastTime);
        }

        return doctors;
    } catch (error) {
        console.error(error, "errorAtReturnAroundDoctorList");

        throw new Error(error);
    }
};

module.exports = {returnAroundDoctorList};