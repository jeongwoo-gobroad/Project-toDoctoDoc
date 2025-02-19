import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_doc/Database/chat_database.dart';
import 'package:to_doc/auth/auth_dio.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/intro.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'auth/auth_secure.dart';
import 'firebase/firebase_handler.dart';

void main() async{
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  //clearSecureStorageOnReinstall();
  initFirebase();
  await initDatabase();
  MobileAds.instance.initialize();

  const Map<String, String> NATIVE_ID = kReleaseMode
    ? {
    

  'ios': '[YOUR iOS AD UNIT ID]',
  'android': 'ca-app-pub-xxxxxxxxxxxxxxxxx/xxxxxxxxx',
  						
}

    :  {
  'ios': 'ca-app-pub-3940256099942544/3986624511',
  'android': 'ca-app-pub-3940256099942544/2247696110',
};
//  AuthRepository.initialize(
  //   appKey: dotenv.env['APP_KEY'] ?? '',
  //   baseUrl: dotenv.env['BASE_URL'] ?? '');
  AuthRepository.initialize(
      appKey: 'd5f01b0b56b0599393d5cae23ae8d69f' ?? '',
      baseUrl: '');

  Get.put(CustomInterceptor());
  Get.put(UserinfoController(), permanent: true);
  Get.put(ChatController(), permanent: true);
  Get.put(ViewController(), permanent: true);


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

clearSecureStorageOnReinstall() async {
  final SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());

  String key = 'hasRunBefore';
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getBool(key) == null) {
    prefs.setBool(key, true);
    return;
  }
  var chk = prefs.getBool(key) as bool;
  if (chk) {
    storage.deleteEveryToken();
  }
  prefs.setBool(key, true);
}