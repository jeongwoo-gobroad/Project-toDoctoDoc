const fcm = require("firebase-admin");
const { getCache } = require("../../../middleware/redisCaching");

const getMessageContext = (token, info) => {
    const message = {
        notification: {
            title: info.title,
            body: info.body,
        },
        data: {
            route: 'main' // flutter 환경에서 알림 클릭시 라우팅 해주기 위한 데이터 없어도 됨
        },
        token: token,
        android:{
            priority: "high",
            notification: {
                channelId: "important_channel" //firebase Channel ID(android_channel_id)
            }
        },
        apns: {
            payload: {
                aps: {// 얘네는 IOS 설정
                    badge: 2.0,
                    "apns-priority": 5,
                    sound: 'default'
                },
            },
        },
    };

    return message;
};

const sendAppointmentDonePushNotification = async (deviceIds, info) => {
    try {
        // console.log(info);
        deviceIds.forEach(async (deviceId) => {
            try {
                await fcm.messaging().send(getMessageContext(JSON.parse((await getCache("Device: " + deviceId))), info));
            } catch (error) {
                console.error(error, "errorAtsendCuratePushNotification");
            }
        });
    } catch (error) {
        console.error(error, "errorAtcurateCuratePushNotification");
    }
};

module.exports = sendAppointmentDonePushNotification;