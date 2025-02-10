import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../../auth/auth_dio.dart';
import 'chat_data_model.dart';
import 'package:to_doc/Database/chat_database.dart';

class ChatController extends GetxController{
  final chatList = <ChatContent>[].obs;
  var isLoading = true.obs;
  final ChatDatabase chatDatabase = ChatDatabase();
  Future<void> requestChat(String doctorID) async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    

    print('의사이이디');
    print(doctorID);

    final response = await dio.post(
      '${Apis.baseUrl}mapp/dm/user/curateScreen',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
      data: json.encode({
        'doctorId': doctorID,
      })
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

  int lastReadId = 0;
  Future<void> getChatList() async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    isLoading.value = true;

    final response = await dio.get(
      '${Apis.baseUrl}mapp/dm/user/list',
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

      chatList.value = [];
      // print(data['content']['recentChat']['role'].toString());
      // print(data['content']['recentChat']['message'].toString());
      for (var chat in data['content']) {
        Map<String, dynamic> temp = {
          'role' : chat['recentChat']['role'].toString(),
          'message' : chat['recentChat']['message'].toString(),
          'createdAt' : chat['recentChat']['createdAt'],
          //DateTime.parse(chat['recentChat']['createdAt'] as String),
          'autoIncrementId' : chat['recentChat']['autoIncrementId'],
        };


        int serverAutoIncrementId = chat['recentChat']['autoIncrementId'];
        print('serverAutoIncremented: ${serverAutoIncrementId}');
        
        lastReadId = await chatDatabase.getLastReadId(chat['cid']); //기존 불러오기
        print('lastreadId : ${lastReadId}');
        
        await chatDatabase.updateLastReadId(chat['cid'], serverAutoIncrementId); //저장장

        // unreadCount = 서버 최신 id - 로컬 마지막 읽은 id
        int unreadCount = serverAutoIncrementId - lastReadId;
        temp['unreadCount'] = unreadCount;
        print('안읽은 개수: ${unreadCount}');
        
        chatList.add(ChatContent.fromMap(chat, temp));
      }
      //_isFetched = true;
      isLoading.value = false;
      return;
    }
    else{
      print('코드: ${response.statusCode}');
    }
    isLoading.value = false;
  }

  
  Future<void> enterChat(String cid, int value) async {
    print('enter chat');
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
      
      
      print('from chat controller joinChat: ${data}');
      //chatList.value = [];
      // print(data['content']['recentChat']['role'].toString());
      // print(data['content']['recentChat']['message'].toString());
      for (var chat in data['content']) {
        print(chat);
        Map<String, dynamic> temp = {
          'role' : chat['role'].toString(),
          'message' : chat['message'].toString(),
          'createdAt' : chat['createdAt'],
          //DateTime.parse(chat['recentChat']['createdAt'] as String),
          'autoIncrementId' : chat['autoIncrementId'],
        };

        chatList.add(ChatContent.fromMap(Null, temp));
      }
      
      
    }
    else{
      print('코드: ${response.statusCode}');
    }
    
  }
}