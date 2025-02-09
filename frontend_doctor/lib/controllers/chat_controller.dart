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

    

    if(response.statusCode == 200){
      final data = json.decode(response.data);
      print(data);

      for (var chat in data['content']) {
        Map<String, dynamic> temp = {
          'role' : chat['recentChat']['role'].toString(),
          'message' : chat['recentChat']['message'].toString(),
          'createdAt' : chat['recentChat']['createdAt'],
          'autoIncrementId' : chat['recentChat']['autoIncrementId'],
        };
        chatList.add(ChatContent.fromMap(chat, temp));
      }
      print(chatList);
    }
    else{
      print('코드: ${response.statusCode}');
    }
    isLoading.value = false;
  }
  Future<void> enterChat(String cid, int value) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());
    String strvalue = value.toString();
    
    final response = await dio.get(
      '${Apis.dmUrl}mapp/dm/joinChat/$cid?readedUntil=$strvalue',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
    );

    if(response.statusCode == 200){
      final data = json.decode(response.data);

      
      print(data);

      
      
    }
    else{
      print('코드: ${response.statusCode}');
    }
    
  }
}