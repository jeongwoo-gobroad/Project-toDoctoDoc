const { returnAroundDoctorList } = require("./aroundDoctorLists");

const sortAroundDoctorListsByScoreWeight = async (fast, dist, star, pLong, pLat, radius) => {
    try {
        let temp = null;
        let index = 0;
        const list = await returnAroundDoctorList(pLong, pLat, parseFloat(radius) * 1000);

        for (const item of list) {
            item.score = parseFloat(fast) * item.timeScore + parseFloat(dist) * item.distanceScore + parseFloat(star) * item.starScore;
        }

        list.sort((a, b) => {
            return b.score - a.score;
        });

        for (let i = 0; i < list.length; i++) {
            if (list[i].myPsyID.isPremiumPsy) {
                temp = list[index];
                list[index] = list[i];
                list[i] = temp;

                index++;
            }
        }

        return list;
    } catch (error) {
        console.log(error, "errorAtSortAroundDoctorListsByScoreWeight");

        throw new Error(error);
    }
};

module.exports = sortAroundDoctorListsByScoreWeight;