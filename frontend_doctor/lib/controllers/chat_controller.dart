import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'auth/auth_interceptor.dart';
import '../model/chat_dart_model.dart';


class ChatController extends GetxController{
  final chatList = <ChatContent>[].obs;
  var isLoading = true.obs;


  Future<void> getChatList() async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    isLoading.value = true;


    final response = await dio.get(
      '${Apis.baseUrl}mapp/dm/doctor/list',
      options:
      Options(headers: {
        'Content-Type':'application/json',
        'accessToken': 'true',
      },),
    );

    print(response);

    if(response.statusCode == 200){
      final data = json.decode(response.data);
      print(data);

      var temp = (data['content'] as List?)?.map((item) => ChatContent.fromMap(item as Map<String, dynamic>)).toList() ?? [];
      print(temp);
      chatList.assignAll(temp);
    }
    else{
      print('코드: ${response.statusCode}');
    }
    isLoading.value = false;
  }
}