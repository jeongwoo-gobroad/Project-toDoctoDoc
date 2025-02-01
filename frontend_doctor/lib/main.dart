import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_doc_for_doc/Database/chat_database.dart';
import 'package:to_doc_for_doc/screen/auth/login_screen.dart';

import 'controllers/auth/auth_secure.dart';
import 'firebase/firebase_handler.dart';

void main() async{
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();

  //clearSecureStorageOnReinstall();
  initFirebase();
  initDatabase();

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
    ),

    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('ko', 'KR'),
    ],

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