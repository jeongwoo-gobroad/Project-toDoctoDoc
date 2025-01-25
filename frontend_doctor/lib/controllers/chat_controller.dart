import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';

import 'auth/auth_interceptor.dart';
import '../screen/chat_dart_model.dart';


class ChatController extends GetxController{
  final chatList = <ChatContent>[].obs;
  final Dio dio;

  ChatController({required this.dio});

  @override
  void onInit() {
    super.onInit();
    dio.interceptors.add(CustomInterceptor());
  }

  Future<void> getChatList() async {
    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/dm/list',
      options:
      Options(headers: {
        'Content-Type':'application/json',
        'accessToken': 'true',
      },
      ),
    );

    print(response);

    if(response.statusCode == 200){
      final data = json.decode(response.data);
      print(data);
      final chatResponse = ChatResponse.fromMap(data);
      chatList.assignAll(chatResponse.content);

    }
    else{
      print('코드: ${response.statusCode}');
    }
  }
}