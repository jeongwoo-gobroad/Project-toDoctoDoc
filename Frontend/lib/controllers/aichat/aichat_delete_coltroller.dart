import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:dio/dio.dart';
import '../../auth/auth_dio.dart';

class AiChatDeleteController extends GetxController{
  var isLoading = false.obs;
  final Dio dio;

  AiChatDeleteController({required this.dio});

  Future<void> deleteOldChat(String chatId) async{
    dio.interceptors.add(CustomInterceptor());
    //로딩
    isLoading.value = true;

    print(chatId);

    final response = await dio.delete(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/aichat/delete/$chatId',
      options: Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
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
