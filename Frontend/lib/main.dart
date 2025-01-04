import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/login_page.dart';
import 'package:to_doc/home.dart';
import 'package:to_doc/navigation_menu.dart';
import 'package:to_doc/provider/auth_provider.dart';
import 'package:to_doc/screens/airesult.dart';
import 'package:to_doc/screens/intro.dart';
import 'package:to_doc/screens/myPost.dart';
import 'package:to_doc/screens/pageView.dart';

void main() async{
 
  runApp(GetMaterialApp(home: Intro()));
}

