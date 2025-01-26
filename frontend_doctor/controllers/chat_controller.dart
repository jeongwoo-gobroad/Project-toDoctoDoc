import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'auth/auth_interceptor.dart';
import '../model/chat_dart_model.dart';


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