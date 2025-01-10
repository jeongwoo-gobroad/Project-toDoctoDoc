import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'chat_data_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
class ChatController extends GetxController{
  socket_io.Socket? socket;
  final chatList = <ChatContent>[].obs;
  var chat = <Map<String, dynamic>>[].obs;
  final ischatFetchLoading = false.obs;

  Future<void> requestChat(String userID, String doctorID) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    
    print(userID);
    print(doctorID);

    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/dm?uid=$userID&did=$doctorID'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      //final data = json.decode(response.body);
      final data = json.decode(json.decode(response.body));
      
    }
    else{
      print('코드: ${response.statusCode}');
    }
  }


  Future<void> getChatList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    ;
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/dm/list'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      final data = json.decode(json.decode(response.body));
      print(data);
      final chatResponse = ChatResponse.fromMap(data);
      chatList.assignAll(chatResponse.content);

     // print(chatResponse.content);
      
    }
    else{
      print('코드: ${response.statusCode}');
    }
  }


  Future<void> initSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        Get.snackbar('Login', '로그인이 필요합니다.');
        print('로그인이 필요합니다.');
        return;
      }

      socket = socket_io.io(
        'http://jeongwoo-kim-web.myds.me:3000/dm',
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({'token': token})
            .setPath('/msg')
            .enableAutoConnect()
            .enableForceNew()
            .disableReconnection()
            .build()
      );

      socket?.onConnect((_) {
        print('Socket 연결 성공');
        fetchChatList();
      });

      socket?.onError((error) {
        print('Socket 에러: $error');
      });

      socket?.onDisconnect((_) => print('Disconnected from server'));

      //chatList 반환데이터
      socket?.on('chatList', (data) {
        
        final decodedData = json.decode(data);
        print(decodedData);
        
      });

      socket?.on('joinChat_user', (data) {
        print('채팅방 입장:');
        
        print(data);
        
      });

      socket?.on('recvChat_user', (_) {
        print('유저 메시지 수신:');
        
        
        
      });
      //환자가 보낸 메시지 수신
      socket?.on('recvChat_doctor', (_) {
        print('의사 메시지 수신:');
        
        
      });

      socket?.on('unread_doctor', (data){
        print('unread doctor section');
        print(data);
      });

      socket?.on('returnChatList', (data) {
        print('받은 채팅 리스트:');
        print(data);
        
      });

      socket?.on('returnJoinedChat', (data) {
        print('받은 joinchat:');
        print(data['chatList']);
        
        chat.value = List<Map<String, dynamic>>.from(data['chatList']);
        ischatFetchLoading.value = false;
        //print(chat);
      });

    } catch (e) {
      print('Socket 초기화 에러: $e');
      Get.snackbar('Error', '연결 중 오류가 발생했습니다.');
    }
  }

  void fetchChatList() {
    print('채팅 리스트 요청 보냄');
    socket?.emit('chatList', null);
  }

  void joinChat(String chatId) {
    ischatFetchLoading.value = true;
    print('채팅방 입장 요청 보냄');
    print(chatId);
    socket?.emit('joinChat_user', chatId);
    
    //socket?.on('joinChat_user', (data) { print(data);} );
  }

  void leaveChat(String chatId) {
    print('채팅방 퇴장 요청 보냄');
    socket?.emit('leaveChat', chatId);
  }

  //유저측 전송
  void sendMessage(String chatId, String message) {
    print('chatId: $chatId');
    print('메시지 전송: $message');
    socket?.emit('sendChat_user', {'roomNo': chatId, 'message': message});
    socket?.emit('sendChat_doctor', {'roomNo': chatId, 'message': message});
    socket?.emit('sendChat', {'roomNo': chatId, 'message': message});
  }



  
}