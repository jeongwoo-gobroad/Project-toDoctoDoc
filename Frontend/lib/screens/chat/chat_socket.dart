import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

//테스트용
class ChatService {
  late IO.Socket _socket;

  // final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('jwt_token');

  //   if(token == null){

  //     Get.snackbar('Login', '로그인이 필요합니다.');
  //     print('로그인이 필요합니다.');
  //   }
  // 소켓 연결 초기화
  void connect(String token) {
    _socket = IO.io(
      'http://jeongwoo-kim-web.myds.me:3000/dm',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token}) 
          .setPath('/msg')
          .enableForceNew() 
          .enableAutoConnect() 
          .build(),
    );

    _socket.onConnect((_) {
      print('Socket connected');
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected');
    });
  }
  // void setupListeners(){
  //   _socket?.on('connect', (_)=> print('Socket connected'));
  // }

  
  void getChatList(Function(List<dynamic> data) onChatListReceived) {
    _socket.emit('chatList');
    _socket.on('returnChatList', (data) {
      onChatListReceived(data);
    });
  }

 
  void joinChat(String roomNo, Function(dynamic chatData) onChatJoined) {
    _socket.emit('joinChat_user', roomNo);
    _socket.on('returnJoinedChat_user', (data) {
      onChatJoined(data);
    });
  }

  
  void leaveChat(String roomNo) {
    _socket.emit('leaveChat_user', roomNo);
  }

  
  void sendMessage(String roomNo, String message) {
    _socket.emit('sendChat_user', {'roomNo': roomNo, 'message': message});
  }

  
  void onMessageReceived(Function(dynamic message) onMessage) {
    _socket.on('recvChat_user', (data) {
      onMessage(data);
    });

    _socket.on('recvChat_doctor', (data) {
      onMessage(data);
    });
  }

  
  void disconnect() {
    _socket.disconnect();
  }
}