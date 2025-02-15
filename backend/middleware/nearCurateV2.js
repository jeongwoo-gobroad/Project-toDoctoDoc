const UserSchema = require("../models/User");
const mongoose = require("mongoose");
const User = mongoose.model('User', UserSchema);

const nearbyPatientCurateV2 = async (long, lat, radius) => {
    const longConstant = 1 / 111.19;
    const latConstant = 1 / (6371 * 1 * Math.PI / 180 * Math.cos(parseFloat(lat) * Math.PI / 180));
    const newLong = parseFloat(long);
    const newLat = parseFloat(lat);
    const newRadius = parseFloat(radius);
    const newUsers = [];

    try {
        const users = await User.find({
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
        }, 'usernick recentCurate recentCurateDate');

        for (let user of users) {
            user = user.toObject();
            newUsers.push(user);
        }

        return newUsers;
    } catch (error) {
        console.error(error, "errorAtNearByPatientCurateV2");

        throw new Error(error);
    }
};

module.exports = nearbyPatientCurateV2;