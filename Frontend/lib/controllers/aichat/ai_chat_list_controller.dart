import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../../auth/auth_dio.dart';


class AiChatListController extends GetxController {
  var chatList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isEmpty = true.obs;

  AiChatListController();

  Future<void> getChatList() async{
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    isLoading.value = true;

    final response = await dio.get(
      '${Apis.baseUrl}mapp/aichat/list',
        options: Options(
          headers: {
            'Content-Type':'application/json',
            'accessToken': 'true',
          },
        )
    );


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

        // print(chatList);
        // print(chatList.length);
        // print(chatList[0]);
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