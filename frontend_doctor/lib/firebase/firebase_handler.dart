import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/auth/auth_secure.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';


Future<void> firebaseStarter() async {
  final SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging fbMsg = FirebaseMessaging.instance;
    String? fcmToken = await fbMsg.getToken(vapidKey: 'BENM2B6kWL-_t2ATlZN2JXE2c4wn0JohHDLTuSUJC5hsKZF-aGUHeBKUW9PPHfukDtb18JLmn1n3yzTj2u5TpHg');

    print("fcm token----: $fcmToken");

    if (storage.readPushToken() == null) {
      storage.savePushToken(fcmToken!);
    }

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _requestNotificationPermission();

    if (!kIsWeb) {
      print('test');
      if (Platform.isIOS) {
        //await reqIOSPermission(fbMsg);
      }
      else if (Platform.isAndroid) {
        AndroidNotificationChannel? androidNotificationChannel;

        print('Platform ------------------- android');
        //Android 8 (API 26) 이상부터는 채널설정이 필수.
        androidNotificationChannel = const AndroidNotificationChannel(
          'important_channel', // id
          'Important_Notifications', // name
          // description
          importance: Importance.high,
        );


        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidNotificationChannel);

        //Background Handling 백그라운드 메세지 핸들링
        FirebaseMessaging.onBackgroundMessage(fbMsgBackgroundHandler);
        //Foreground Handling 포어그라운드 메세지 핸들링
        FirebaseMessaging.onMessage.listen((message) {
          fbMsgForegroundHandler(message, flutterLocalNotificationsPlugin,
              androidNotificationChannel);
        });
        //Message Click Event Implement
        await setupInteractedMessage(fbMsg);
      }
    }
  }
  catch (e){
    print('initErr $e');
  }
}

Future<void> _requestNotificationPermission() async {
  PermissionStatus status = await Permission.notification.status;

  if (status.isGranted) {
    print('permission ----------------------------- Granted');
    // 권한이 허용되었을 때 추가 작업 수행
  } else {
    await Permission.notification.request();
  }
}


Future<void> fbMsgBackgroundHandler(RemoteMessage message) async {
  print("[FCM - Background] MESSAGE : ${message.messageId}");
}

Future<void> fbMsgForegroundHandler(
    RemoteMessage message,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    AndroidNotificationChannel? channel) async {

  print('[FCM - Foreground] MESSAGE : ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
    flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel!.id,
            channel.name,
            //channel.description,
            icon: '@mipmap/ic_launcher',
          ),
          // iOS: const DarwinNotificationDetails(
          //   badgeNumber: 1,
          //   subtitle: 'the subtitle',
          //   sound: 'slow_spring_board.aiff',
          // ),
        ));
  }
}

/// FCM 메시지 클릭 이벤트 정의
Future<void> setupInteractedMessage(FirebaseMessaging fbMsg) async {
  RemoteMessage? initialMessage = await fbMsg.getInitialMessage();
  // 종료상태에서 클릭한 푸시 알림 메세지 핸들링
  if (initialMessage != null) clickMessageEvent(initialMessage);
  // 앱이 백그라운드 상태에서 푸시 알림 클릭 하여 열릴 경우 메세지 스트림을 통해 처리
  FirebaseMessaging.onMessageOpenedApp.listen(clickMessageEvent);
}

void clickMessageEvent(RemoteMessage message) {
  var data = message.data;
  print(data);

  // 로그인 -> 홈화면 -> 채팅 화면
  // 연달아서 다 들어가야 함 ...

}