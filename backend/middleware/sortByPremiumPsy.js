const Premium_Psychiatry = require("../models/Premium_Psychiatry");

const topExposureForPremiumPsy = async (list) => {
    let index = 0;

    for (let i = 0; i < list.length; i++) {
        const place_id = list[i].id;

        if (await Premium_Psychiatry.findOne({place_id: place_id})) {
            list[i].isPremiumPsychiatry = true;
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
};

module.exports = topExposureForPremiumPsy;