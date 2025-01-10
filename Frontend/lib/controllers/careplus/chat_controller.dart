import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';

class ChatController extends GetxController{
  Future<void> requestChat(String userID, String doctorID) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    
    print(userID);
    print(doctorID);

    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/dm?uid=$userID&did=$doctorID'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      final data = json.decode(json.decode(response.body));
      print(data);
    }
    else{
      print('코드: ${response.statusCode}');
    }
  }

  Future<void> getChatList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    ;
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/dm/list'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      final data = json.decode(json.decode(response.body));
      print(data);
    }
    else{
      print('코드: ${response.statusCode}');
    }
  }

  Future<void> getChatContent(String chatID) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    ;
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/dm/$chatID'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      final data = json.decode(json.decode(response.body));
      print(data);
    }
    else{
      print('코드: ${response.statusCode}');
    }
  }
}