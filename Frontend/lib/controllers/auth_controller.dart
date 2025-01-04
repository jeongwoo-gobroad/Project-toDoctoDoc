import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/provider/auth_provider.dart';


class AuthController extends GetxController{
  final authProvider = Get.put(AuthProvider());


  // Future<bool> login(String userid, String password) async{
  //   Map body = await authProvider.login(userid,password);
  //   // if(body['success'] == true){
  //   //   String token = body
  //   // }
  // }





}