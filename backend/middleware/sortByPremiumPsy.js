const Psychiatry = require("../models/Psychiatry");

const topExposureForPremiumPsy = async (list) => {
    let index = 0;

    if (Array.isArray(list)) {
        for (let i = 0; i < list.length; i++) {
            const place_id = list[i].id;
            
            const psy = await Psychiatry.findOne({place_id: place_id});

            if (psy && psy.isPremiumPsy) {
                list[i].isPremiumPsychiatry = true;
                list[i].stars = psy.stars;
                list[i].pid = psy._id;
                /* swap */
                const temp = list[index];
                list[index] = list[i];
                list[i] = temp;
                index++;
            } else {
                list[i].isPremiumPsychiatry = false;
            }
        }
    
        return list;
    }

    console.log("Error at topExposureForPremiumPsy: ", list);

    return null;
};

module.exports = topExposureForPremiumPsy;