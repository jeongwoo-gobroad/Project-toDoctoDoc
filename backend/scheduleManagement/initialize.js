const mongoose = require("mongoose");
const Doctor = require("../models/Doctor");
const UserSchema = require("../models/User");
const Schedule = require("../models/Schedule");
const User = mongoose.model('User', UserSchema);

const initSchedule = async (userid, isDoctor, isCounselor) => {
    let user = null;

    try {
        if (isDoctor) {
            user = await Doctor.findById(userid);
        } else if (isCounselor) {
            // user = await Counselor.findById(userid);
        } else {
            user = await User.findById(userid);
        }

        const schedule = await Schedule.create({
            isDoctor: isDoctor,
            isCounselor: isCounselor,
            userid: userid,
            availableTime: [
                [ // 월요일
                    {
                        from: '00:00',
                        to: '24:00',
                        memo: "개인 시간",
                        isAvailableTime: false
                    }
                ],
                [ // 화요일
                    {
                        from: '00:00',
                        to: '24:00',
                        memo: "개인 시간",
                        isAvailableTime: false
                    }
                ],
                [ // 수요일
                    {
                        from: '00:00',
                        to: '24:00',
                        memo: "개인 시간",
                        isAvailableTime: false
                    }
                ],
                [ // 목요일
                    {
                        from: '00:00',
                        to: '24:00',
                        memo: "개인 시간",
                        isAvailableTime: false
                    }
                ],
                [ // 금요일
                    {
                        from: '00:00',
                        to: '24:00',
                        memo: "개인 시간",
                        isAvailableTime: false
                    }
                ],
                [ // 토요일
                    {
                        from: '00:00',
                        to: '24:00',
                        memo: "개인 시간",
                        isAvailableTime: false
                    }
                ],
                [ // 일요일
                    {
                        from: '00:00',
                        to: '24:00',
                        memo: "개인 시간",
                        isAvailableTime: false
                    }
                ],
            ]
        });

        user.schedule = schedule._id;

        await user.save();

        return;
    } catch (error) {
        console.log(error, "errorAtInitSchedule");

        throw new Error(error);
    }
};

module.exports = initSchedule;