import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:to_doc/chat_object.dart';

class AichatLoadController extends GetxController {
  var isLoading = false.obs;
  final List<ChatObject> messageList = [];

  Future<bool> loadChat(String chatId) async {
    print('chat Loading');
    print(chatId);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if(token == null){
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return false;
    }


    isLoading.value = true;
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/aichat/get/$chatId'),
      headers: {
        'Content-Type':'application/json',
        'authorization':'Bearer $token',
      },
    );

    if(response.statusCode==200){
      final data = json.decode(json.decode(response.body));

      print('loading');
      print(data);

      List<dynamic> contentList = data['content']['response'];

      //print('response');
      //print(contentList);

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