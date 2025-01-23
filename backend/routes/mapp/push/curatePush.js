const fcm = require("firebase-admin");

const sendCuratePushNotification = async (deviceToken, info) => {
    const message = {
        notification: {
            title: info.title,
            body: info.body,
        },
        data: {
            route: 'main' // flutter 환경에서 알림 클릭시 라우팅 해주기 위한 데이터 없어도 됨
        },
        android:{
            priority: "high",
            notification: {
                channelId: null //firebase Channel ID(android_channel_id)
            }
        },
        token: deviceToken,
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

    try {
        // console.log(fcm);
        await fcm.getMessaging().sendMulticast(message);
    } catch (error) {
        console.error(error, "errorAtsendCuratePushNotification");
    }
};

module.exports = sendCuratePushNotification;