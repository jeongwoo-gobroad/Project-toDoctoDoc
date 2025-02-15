const Doctor = require("../models/Doctor");
const {DateTime} = require('luxon');
const closePsychiatryFinding = require("./closePlaceCurate");
const { getNearestDateInMomentType, diffAsMinutes } = require("./closeTimeCurate");

const returnAroundDoctorList = async (patientLong, patientLat, radius) => {
    try {
        const longConstant = 1 / 111.19;
        const latConstant = 1 / (6371 * 1 * Math.PI / 180 * Math.cos(parseFloat(patientLat) * Math.PI / 180));
        const newLong = parseFloat(patientLong);
        const newLat = parseFloat(patientLat);
        const newRadius = parseFloat(radius);
        const returnValueDoctors = [];

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
        let shortestDistance = 5000;
        let longestTime = 0;

        for (const psy of psys) {
            psyMap.set(psy.id.toString(), psy.distance);

            if (parseInt(psy.distance) < parseInt(shortestDistance)) {
                shortestDistance = psy.distance;
            }
        }

        for (let doctor of doctors) {
            doctor = doctor.toObject();

            if (psyMap.has(doctor.myPsyID.place_id)) {
                doctor.distanceScore = shortestDistance / psyMap.get(doctor.myPsyID.place_id);
            } else {
                doctor.distanceScore = 0;
            }

            doctor.starScore = doctor.myPsyID.stars / 5;

            if (doctor.schedule) {
                doctor.leastTime = await getNearestDateInMomentType(doctor.schedule.availableTime, doctor._id, doctor.schedule.minimalAppointmentTime);

                if (doctor.leastTime && diffAsMinutes(DateTime.now(), doctor.leastTime) > longestTime) {
                    longestTime = doctor.leastTime;
                }
            } else {
                doctor.leastTime = DateTime.fromISO("2099-12-31T23:59:59.500+00:00");
            }

            returnValueDoctors.push(doctor);
        }

        for (const doctor of returnValueDoctors) {
            doctor.timeScore = (longestTime - DateTime.now()) / (doctor.leastTime - DateTime.now());
        }

        return returnValueDoctors;
    } catch (error) {
        console.error(error, "errorAtReturnAroundDoctorList");

        throw new Error(error);
    }
};

module.exports = {returnAroundDoctorList};