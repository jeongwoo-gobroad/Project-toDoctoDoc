const Psy = require("../models/Psychiatry");

/* Be aware of Race Condition! */
const reviewRefreshWorks = async (psyId, prevRating, newRating, status) => {
    let newRecord = null;

    try {
        const psy = await Psy.findById(psyId);

        let previous = null;

        if (status === -1) {
            /* Update */
            previous = psy.stars * (psy.reviews.length - 1);
            console.log("Review Added");
            newRecord = (previous + newRating) / (psy.reviews.length);
        } else if (status === 0) {
            /* Edit */
            previous = psy.stars * (psy.reviews.length);
            console.log("Review Fixed");
            newRecord = (previous - prevRating + newRating) / (psy.reviews.length);
        } else {
            /* Deletion */
            console.log("Review Deleted");
            if (psy.reviews.length === 0) {
                newRecord = 0;
            } else {
                previous = psy.stars * (psy.reviews.length + 1);
                newRecord = (previous - prevRating) / (psy.reviews.length);
            }
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