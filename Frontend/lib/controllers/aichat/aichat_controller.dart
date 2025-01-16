import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:dio/dio.dart';
import '../../auth/auth_dio.dart';

class AiChatController extends GetxController{
  final Dio dio;

  var chatId = '';
  var firstChat = '';

  var isLoading = false.obs;

  AiChatController({required this.dio});

  Future<void> getNewChat() async{
    dio.interceptors.add(CustomInterceptor());
    isLoading.value = true;


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
