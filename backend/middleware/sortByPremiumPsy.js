const Premium_Psychiatry = require("../models/Premium_Psychiatry");

const topExposureForPremiumPsy = async (list) => {
    let index = 0;

    if (Array.isArray(list)) {
        for (let i = 0; i < list.length; i++) {
            const place_id = list[i].id;
            
            const psy = await Premium_Psychiatry.findOne({place_id: place_id});

            if (psy) {
                list[i].isPremiumPsychiatry = true;
                list[i].stars = psy.stars;
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