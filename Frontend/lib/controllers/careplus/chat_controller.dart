import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:convert';
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

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/dm/user/list',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
    );

    if(response.statusCode == 200){
      final data = json.decode(response.data);

      print('chatlist');
      print(data);

      var temp = (data['content'] as List?)?.map((item) => ChatContent.fromMap(item as Map<String, dynamic>)).toList() ?? [];

      print(temp);

      //final chatResponse = ChatResponse.fromMap(data);
      chatList.assignAll(temp);

     // print(chatResponse.content);
      
    }
    else{
      print('코드: ${response.statusCode}');
    }
  }
}