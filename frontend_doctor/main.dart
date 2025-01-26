import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:to_doc_for_doc/screen/auth/login_screen.dart';

void main() async{
  await initializeDateFormatting();

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