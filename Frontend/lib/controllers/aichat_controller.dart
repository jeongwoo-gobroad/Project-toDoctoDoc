import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:dio/dio.dart';
import '../auth/auth_dio.dart';

class AiChatController extends GetxController{
  final Dio dio;

  var chatId = '';
  var firstChat = '';

  var isLoading = false.obs;

  AiChatController({required this.dio});

  Future<void> getNewChat() async{
    dio.interceptors.add(CustomInterceptor());
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

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/aichat/new',
      options : Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },
      )
    );

    if(response.statusCode == 200){
      final data = json.decode(response.data);
      print(data);

      chatId = data['content']['chatid'];
      firstChat = data['content']['startingMessage'];
    }
    else {
      Get.snackbar('Error', '채팅을 생성하지 못했습니다. ${response.statusCode})');
      return;
    }
    isLoading.value = false;
  }
}
