import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';


class AiChatListController extends GetxController {
  var chatList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isEmpty = true.obs;

  Future<void> getChatList() async{
    isLoading.value = true;

    //토큰? Access Token으로 접근하고 1회 실패하면 Refresh Token으로 접근하면 되고, Refresh Token으로 접근하면 헤더에 Access_Token에 Access Token을 담고 Refresh_token에 Refresh Token을 담아서 줌.
    /* if token == null -> 로그인이 필요합니다. */

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    print('로그인중');

    if(token == null){
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }


    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/aichat/list'),
      headers: {
        'Content-Type':'application/json',
        'authorization':'Bearer $token',
      },

    );

    if(response.statusCode == 200){
      isEmpty.value = false;

    final data = json.decode(json.decode(response.body));
      print(data);

      if(data is Map<String,dynamic> && data['content'] is List) {
        List<dynamic> contentList = data['content'];
        //데이터
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
        print(chatList[0]['title']);
      }
      isLoading.value = false;
      return;
    }
    else if (response.statusCode == 201) {
      isEmpty.value = true;
      isLoading.value = false;
      return;
    }
    else {
      isEmpty.value = true;
      Get.snackbar('Error', '채팅 목록을 받아오지 못했습니다. ${response.statusCode})');
      isLoading.value = false;
      return;
    }
    isLoading.value = false;
    return;
  }


  //25-01-05T14:11:13.068Z

}