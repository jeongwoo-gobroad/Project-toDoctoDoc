import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:to_doc/app.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/intro.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

void main() async{
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();

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

