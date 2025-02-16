import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:to_doc_for_doc/Database/chat_database.dart';
import 'package:to_doc_for_doc/controllers/AIassistant/ai_assistant_controller.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';
import 'package:to_doc_for_doc/screen/auth/login_screen.dart';

void main() async{
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();

  await GetStorage.init();
  Get.put(CustomInterceptor());
  Get.put(AiAssistantController(), permanent: true);
  runApp(GetMaterialApp(
    home: LoginPage(),
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