import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:dio/dio.dart';
import '../../auth/auth_dio.dart';

class AiChatSaveController extends GetxController{
  var isLoading = false.obs;
  final Dio dio;

  AiChatSaveController({required this.dio});

  Future<void> saveChat(String chatId) async {
    dio.interceptors.add(CustomInterceptor());
    print(chatId);

    //토큰? Access Token으로 접근하고 1회 실패하면 Refresh Token으로 접근하면 되고, Refresh Token으로 접근하면 헤더에 Access_Token에 Access Token을 담고 Refresh_token에 Refresh Token을 담아서 줌.
    /* if token == null -> 로그인이 필요합니다. */

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    print(token);

    /*
    if(token == null){
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    */


    try {
      final response = await dio.post(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/aichat/save',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accessToken': 'true',
          },
        ),
        data: json.encode({'chatid': chatId,}),
      );

      //print('response code ${response.statusCode}');

      if (response.statusCode == 200) {
        print('saved');
        Get.snackbar('Success', '채팅을 저장했습니다. ${response.statusCode})');
      }
      else {
        Get.snackbar('Error', '채팅을 저장하지 못했습니다. ${response.statusCode})');
        return;
      }
      isLoading.value = false;
    } catch (e) {
      Get.snackbar("오류", "문제가 발생했습니다. 다시 시도해주세요.");
      return;
    }
  }
}
