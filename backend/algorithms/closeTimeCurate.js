const moment = require("moment");
const Appointment = require("../models/Appointment");

const makeScheduleAsTime = (timeString, dateAdded) => {
    return moment((moment().add(dateAdded, 'days').format('YYYY-MM-DD') + 'T' + timeString));
};

const diffAsMinutes = (from, to) => {
    const a = moment.duration(from);
    const b = moment.duration(to);

    return b.subtract(a).asMinutes();
};

/*
 * 알고리즘 명세
    이 알고리즘은 약속은 ISODate로 기록된 절대시각임을, 스케줄은 주마다 반복되는 상대시각적인 요소임을
    고려하여 자료구조가 설계된 것에 최적화된 알고리즘이다.

    먼저 의사가 보유한 약속 중 현재 시간보다 더 뒤에 있는 약속부터 모든 약속을 받아온다.

    그다음, 다가오는 32일 중 leastTime만큼의 시간을 제공할 수 있으면서, 의사 개인의 진료 시간 중인 시간을 추천 해 준다.

    그 원리는 아래와 같다:
        stt와 end라는 객체명으로 각 약속의 시작시각과 종료시각을 기록한다.
        다가오는 32일 동안을 반복한다:
            만약 기간 내 첫 영업 가능 시각이 안 정해지고, 이번 반복되는 요일이 영업하는 요일이면 첫 진료 시각을 기록한다.

            그 다음, 영업 가능 시각이 아닌 시각을 약속이 정해져 있는 것으로 취급하도록 만든다.
                이때 prevLoop 변수를 활용하여 주말 등 하루가 통으로 비어 있는 시간 및 오늘에서 내일로 이어지는 시간을
                기록할 수 있다.
            
        그다음, 위 약속들을 시작 시각대로 정렬한다: 최소 회의실 문제 알고리즘의 응용이다.

        그 이후 루프를 돌면서 leastTime 만큼의 시간을 제공해 줄 수 있는 첫 시간을 찾는다.

        그 값이 있다면 null이 아닌 값을 반환한다.
 */

const getNearestDateInMomentType = async (availableTime, doctorId, leastTime) => {
    try {
        const appointments = await Appointment.find({
            $and: [
                {doctor: doctorId},
                {appointmentTime: {$gte: moment()}}
            ]
        });
        const array = [];
        const date = moment(moment()).day();
        let start = null;
        let rtnVal = null;

        for (const app of appointments) {
            array.push({
                stt: moment(app.appointmentTime),
                end: moment(app.appointmentEndAt)
            })
        }

        let prevLoop = null;
        for (let day = 0; day < 32; day++) {
            const loopDate = (date + day) % 7;

            if (start === null && availableTime[loopDate].length > 0) {
                start = availableTime[loopDate][0];
            }

            for (let i = 0; i < availableTime[loopDate].length - 1; i++) {
                if (prevLoop) { // first loop, i = 0 and prevLoop exists
                    array.push({
                        stt: prevLoop,
                        end: makeScheduleAsTime(availableTime[loopDate][i], day)
                    })
                    prevLoop = null;
                }
                array.push({
                    stt: makeScheduleAsTime(availableTime[loopDate][i], day),
                    end: makeScheduleAsTime(availableTime[loopDate][i + 1], day)
                });
            }

            if (availableTime[loopDate].length > 0) {
                prevLoop = makeScheduleAsTime(availableTime[loopDate][availableTime[loopDate].length - 1]);
            }
        }

        array.sort((a, b) => {
            return moment(a.stt).subtract(moment(b.stt));
        });

        for (const item of array) {
            if (diffAsMinutes(start, item.stt) >= leastTime && diffAsMinutes(start, moment()) > 0) {
                rtnVal = start;

                break;
            }

            start = item.end;
        }

        return rtnVal;
    } catch (error) {
        console.error(error, "errorAtGetNearestDateInMomentType");

        throw new Error(error);
    }
};

module.exports = {diffAsMinutes, getNearestDateInMomentType};