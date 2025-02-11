const fcm = require("firebase-admin");
const Redis = require("../../../config/redisObject");

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

const sendDMPushNotification = async (deviceIds, info) => {
    try {
        let redis = new Redis();

        await redis.connect();

        for (const deviceId of deviceIds) {
            try {
                let cache = null;
                if ((cache = await redis.getCache("DEVICE:" + deviceId))) {
                    await fcm.messaging().send(getMessageContext(cache, info));
                }
            } catch (error) {
                console.error(error, "errorAtsendCuratePushNotification");
            }
        }

        redis.closeConnnection();
        redis = null;
    } catch (error) {
        console.error(error, "errorAtsendDMPushNotification");
    }
};

module.exports = sendDMPushNotification;