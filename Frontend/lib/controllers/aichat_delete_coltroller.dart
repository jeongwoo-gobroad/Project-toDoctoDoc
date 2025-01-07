import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AiChatDeleteController extends GetxController{
  var isLoading = false.obs;

  Future<void> deleteOldChat(String chatId) async{
    //로딩
    isLoading.value = true;

    //토큰? Access Token으로 접근하고 1회 실패하면 Refresh Token으로 접근하면 되고, Refresh Token으로 접근하면 헤더에 Access_Token에 Access Token을 담고 Refresh_token에 Refresh Token을 담아서 줌.
    /* if token == null -> 로그인이 필요합니다. */

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    print('로그인중');

    if(token == null){
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }

    print(chatId);

    final response = await http.delete(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/aichat/delete/$chatId'),
      headers: {
        'Content-Type':'application/json',
        'authorization':'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      Get.snackbar('Success', '채팅을 삭제했습니다. ${response.statusCode})');
    }
    else {
      Get.snackbar('Error', '채팅을 삭제하지 못했습니다. ${response.statusCode})');
      return;
    }
    isLoading.value = false;
  }




}
