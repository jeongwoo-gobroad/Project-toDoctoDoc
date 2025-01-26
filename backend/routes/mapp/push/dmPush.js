const fcm = require("firebase-admin");

const getMessageContext = (token, info) => {
    const message = {
        notification: {
            title: info.title,
            body: info.body.message,
        },
        data: {
            route: 'main' // flutter 환경에서 알림 클릭시 라우팅 해주기 위한 데이터 없어도 됨
        },
        token: token,
        android:{
            priority: "high",
            notification: {
                channelId: null //firebase Channel ID(android_channel_id)
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

const sendDMPushNotification = async (deviceToken, info) => {
    try {
        // console.log(info);
        deviceIds.forEach(async (deviceId) => {
            try {
                await fcm.messaging().send(getMessageContext(await getCache("Device: " + deviceId), info));
            } catch (error) {
                console.error(error, "errorAtsendDMPushNotification");
            }
        });
    } catch (error) {
        console.error(error, "errorAtsendDMPushNotification");
    }
};

module.exports = sendDMPushNotification;