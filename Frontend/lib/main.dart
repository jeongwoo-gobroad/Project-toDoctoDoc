import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:to_doc/app.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/intro.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'auth/auth_secure.dart';
import 'firebase_options.dart';
import 'firebase_handler.dart';

void main() async{
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();

  final SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging fbMsg = FirebaseMessaging.instance;
  String? fcmToken = await fbMsg.getToken(vapidKey: "BGRA_GV..........keyvalue");
  print("fcm token----: $fcmToken");

  if (storage.readPushToken() == null) {
    storage.savePushToken(fcmToken!);
  }
/*  fbMsg.onTokenRefresh.listen((nToken) {

    //TODO : 서버에 해당 토큰을 저장하는 로직 구현
  });*/

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel? androidNotificationChannel;

  if (Platform.isIOS) {
    //await reqIOSPermission(fbMsg);
  }
  else if (Platform.isAndroid) {
    print('Platform ------------------- android');
    //Android 8 (API 26) 이상부터는 채널설정이 필수.
    androidNotificationChannel = const AndroidNotificationChannel(
      'important_channel', // id
      'Important_Notifications', // name
      // description
      importance: Importance.high,
    );

    _requestNotificationPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  //Background Handling 백그라운드 메세지 핸들링
  FirebaseMessaging.onBackgroundMessage(fbMsgBackgroundHandler);
  //Foreground Handling 포어그라운드 메세지 핸들링
  FirebaseMessaging.onMessage.listen((message) {
    fbMsgForegroundHandler(message, flutterLocalNotificationsPlugin, androidNotificationChannel);
  });
  //Message Click Event Implement
  await setupInteractedMessage(fbMsg);

//  AuthRepository.initialize(
  //   appKey: dotenv.env['APP_KEY'] ?? '',
  //   baseUrl: dotenv.env['BASE_URL'] ?? '');
  AuthRepository.initialize(
      appKey: 'd5f01b0b56b0599393d5cae23ae8d69f' ?? '',
      baseUrl: '');

  Get.put(UserinfoController(dio:Dio()), permanent: true);
  Get.put(ViewController(dio:Dio()), permanent: true);
  runApp(GetMaterialApp(
    scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    // getPages: [
    // //GetPage(name: '/', page: () => Intro()),
    // GetPage(name: '/navigationmenu', page: () => NavigationMenu()), // 라우트 이름 등록
    // GetPage(name: '/myposttemp', page: () => MypostTemp()),
    // ],
    home: Intro(),
    theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(255, 255, 255, 100),
        navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(backgroundColor: Colors.white, scrolledUnderElevation: 0),
        menuBarTheme: MenuBarThemeData(),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
        )
    )
  ));
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