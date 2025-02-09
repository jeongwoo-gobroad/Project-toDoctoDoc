const Curate = require("../models/Curate");

const nearbyPatientCurate = async (long, lat, radius) => {
    const longConstant = 1 / 111.19;
    const latConstant = 1 / (6371 * 1 * Math.PI / 180 * Math.cos(parseFloat(lat) * Math.PI / 180));
    const nearCurates = [];

    const curates = await Curate.aggregate([
        {
            $lookup: {
                from: 'users',
                let: {uid: "$user"},
                pipeline: [
                    {
                        $match:
                        {
                            $expr:
                            {
                                $and: [
                                    {$eq: ["$_id", "$$uid"]},
                                    {$gte: ["$address.longitude", parseFloat(long) - parseFloat(radius) * longConstant]},
                                    {$lte: ["$address.longitude", parseFloat(long) + parseFloat(radius) * longConstant]},
                                    {$gte: ["$address.latitude", parseFloat(lat) - parseFloat(radius) * latConstant]},
                                    {$lte: ["$address.latitude", parseFloat(lat) + parseFloat(radius) * latConstant]},
                                ]
                            }
                        }
                    }
                ],
                as: 'user'
            },
        },
        {
            $match: {
                'user.address': {$exists: true}
            }
        },
        {
            $project: {
                'user.usernick': 1,
                'date': 1,
                'createdAt': 1,
                'comments': 1,
            }
        }
    ]);

    return curates;
};

module.exports = nearbyPatientCurate;