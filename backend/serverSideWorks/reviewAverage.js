const PremiumPsy = require("../models/Premium_Psychiatry");
const Psy = require("../models/Psychiatry");

const reviewRefreshWorks = async (psyId, isPremium, prevRating, newRating, status) => {
    let psy = null;
    let newRecord = null;

    try {
        if (isPremium) {
            psy = await PremiumPsy.findById(psyId);
        } else {
            psy = await Psy.findById(psyId);
        }

        const previous = psy.stars * psy.reviews.length;

        if (status === -1) {
            /* Update */
            console.log("Review Added");
            newRecord = (previous + newRating) / (psy.reviews.length + 1);
        } else if (status === 0) {
            /* Edit */
            console.log("Review Fixed");
            newRecord = (previous - prevRating + newRating) / (psy.reviews.length);
        } else {
            /* Deletion */
            console.log("Review Deleted");
            newRecord = (previous - prevRating) / (psy.reviews.length - 1);
        }

        psy.stars = newRecord;

        await psy.save();

        return;
    } catch (error) {
        console.error(error, "errorAtReviewRefreshWorks");

        return;
    }
};

module.exports = reviewRefreshWorks;