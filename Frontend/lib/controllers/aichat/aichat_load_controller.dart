import 'package:get/get.dart';
import 'dart:convert';
import 'package:to_doc/chat_object.dart';

import 'package:dio/dio.dart';
import '../../auth/auth_dio.dart';

class AichatLoadController extends GetxController {
  var isLoading = false.obs;
  final List<ChatObject> messageList = [];

  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();

  Future<bool> loadChat(String chatId) async {
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    isLoading.value = true;

    print('chat Loading');
    print(chatId);

    final response = await dio.get(
      '${Apis.baseUrl}mapp/aichat/get/$chatId',
      options: Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      )
    );


    if(response.statusCode==200){
      final data = json.decode(response.data);

      print('loading');
      print(data);

      List<dynamic> contentList = data['content']['response'];

      for (var chat in contentList) {
        if (chat['role'] == 'user') {
          messageList.add(ChatObject(content: chat['content'], role: 'user', createdAt: DateTime.now()));
        }
        else {
          messageList.add(ChatObject(content: chat['content'], role: 'ai', createdAt: DateTime.now()));
        }
      }

      //chatData.sort((a, b) => DateTime.parse(a['chatEditedAt']).compareTo(DateTime.parse(b['chatEditedAt'])) //정렬);
      //chat.refresh();
      //시간형식: "2025-01-02T11:17:48.062Z\"

      print('load end');

      //print('게시물 data: ${posts.value}');
      isLoading.value = false;
      return true;
    }
    else{
      Get.snackbar('Error', '채팅을 불러오지 못했습니다. ${response.statusCode})');
      return false;
    }
  }
}