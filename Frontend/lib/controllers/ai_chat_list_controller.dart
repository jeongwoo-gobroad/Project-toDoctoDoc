import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

import '../auth/auth_dio.dart';


class AiChatListController extends GetxController {
  var chatList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isEmpty = true.obs;
  final Dio dio;

  AiChatListController({required this.dio,});

  Future<void> getChatList() async{
    dio.interceptors.add(CustomInterceptor());

    isLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    print('로그인중');


    if(token == null){
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }

    final response = await dio.get(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/aichat/list',
        options: Options(
          headers: {
            'Content-Type':'application/json',
            'accessToken': 'true',
          },
        )
    );

    /*
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/aichat/list'),
      headers: {
        'Content-Type':'application/json',
        'authorization':'Bearer $token',
      },
    );
    */

    if(response.statusCode == 200){
      isEmpty.value = false;

      final data = json.decode(response.data);

      if(data is Map<String,dynamic> && data['content'] is List) {
        List<dynamic> contentList = data['content'];
        for (var post in contentList) {
          chatList.value = (data['content'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
          //print('Title: ${post['title']} Tag : ${post['tag']}');
        }

        chatList.value.sort((a, b) =>
            DateTime.parse(b['chatEditedAt']).compareTo(
                DateTime.parse(a['chatEditedAt'])) //정렬
        );
        chatList.refresh();

        print(chatList);
        print(chatList.length);
        print(chatList[0]);
      }
    }
    else if (response.statusCode == 201) {
      isEmpty.value = true;
    }
    else {
      isEmpty.value = true;
      Get.snackbar('Error', '채팅 목록을 받아오지 못했습니다. ${response.statusCode})');
    }
    isLoading.value = false;
    return;
  }
}