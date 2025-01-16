import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import '../../auth/auth_dio.dart';
import 'chat_data_model.dart';


class ChatController extends GetxController{
  final chatList = <ChatContent>[].obs;
  final Dio dio;

  ChatController({required this.dio});

  @override
  void onInit() {
    super.onInit();
    dio.interceptors.add(CustomInterceptor());
  }

  Future<void> requestChat(String userID, String doctorID) async {
/*    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }*/

    print('유저아이디');
    print(userID);

    print('의사이이디');
    print(doctorID);

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/dm?uid=$userID&did=$doctorID',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
    );

    print(response);
    if(response.statusCode == 200){
      print('채팅방 코드');
      final data = json.decode(response.data);
      print(data);
    }
    else{
      print('코드: ${response.statusCode}');
    }
  }


  Future<void> getChatList() async {
/*    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }*/


    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/dm/list',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
    );

/*    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/dm/list'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );*/

    if(response.statusCode == 200){
      final data = json.decode(response.data);

      print('chatlist');
      print(data);
      final chatResponse = ChatResponse.fromMap(data);
      chatList.assignAll(chatResponse.content);

     // print(chatResponse.content);
      
    }
    else{
      print('코드: ${response.statusCode}');
    }
  }
}