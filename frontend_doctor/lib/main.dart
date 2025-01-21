import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:to_doc_for_doc/navigators/navigation_menu.dart';
import 'package:to_doc_for_doc/src/auth/login_screen.dart';
import 'package:to_doc_for_doc/src/home.dart';

void main() async{
  await initializeDateFormatting();

  runApp(GetMaterialApp(
    home: LoginPage()));


}