import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/login_page.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/home.dart';
import 'package:to_doc/navigation_menu.dart';
import 'package:to_doc/provider/auth_provider.dart';
import 'package:to_doc/screens/airesult.dart';
import 'package:to_doc/screens/intro.dart';
import 'package:to_doc/screens/myPost.dart';
import 'package:to_doc/screens/pageView.dart';
import 'package:to_doc/screens/user_edit.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  

  //  AuthRepository.initialize(
  //   appKey: dotenv.env['APP_KEY'] ?? '',
  //   baseUrl: dotenv.env['BASE_URL'] ?? '');
  AuthRepository.initialize(
      appKey: 'd5f01b0b56b0599393d5cae23ae8d69f' ?? '',
      baseUrl: '');

  Get.put(UserinfoController(), permanent: true);
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
    home: Intro()));
}

