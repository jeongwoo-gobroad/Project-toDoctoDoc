/*
import 'dart:convert';
import 'package:get/get.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';

class ChatSocketService {
  //var chat = <Map<String, dynamic>>[].obs;
  final ischatFetchLoading = false.obs;

  late io.Socket socket;
  late var RoomCode;
  bool chatOngoing = false;

  ChatSocketService(String token) {
    try {
      socket = io.io(
          'http://jeongwoo-kim-web.myds.me:3000/dm',
          io.OptionBuilder()
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
        socket?.emit('chatList', null);
      });

      socket?.onError((error) {
        print('Socket 에러: $error');
      });

      socket?.onDisconnect((_) => print('Disconnected from server'));

      socket?.on('joinChat_doctor', (data) {
        print('채팅방 입장:');
        print(data);
      });


    } catch (e) {
      print('Socket 초기화 에러: $e');
      Get.snackbar('Error', '연결 중 오류가 발생했습니다.');
    }
  }

  void onUnread_user(Function callback) {
    socket?.on('unread_user', (data) => callback(data));
  }

  void onReturnJoinedChat_user(Function callback) {
    socket?.on('returnJoinedChat_user', (data) => callback(data));
  }

  void onReturnJoinedChat_doctor(Function callback) {
    socket?.on('returnJoinedChat_doctor', (data) => callback(data));
    print('받은 joinchat:');
  }

  void onMsgListReceived(Function callback) {
    socket?.on('chatList', (data) => callback(data));
  }

  void onUserReceived(Function callback) {
    socket?.on('recvChat_user', (data) => callback(data));

    print('유저 메세지 수신');
  }
  void onDoctorReceived(Function callback) {
    socket?.on('recvChat_doctor', (data) =>callback(data));
    print('의사 메시지 수신:');
  }

  void joinChat(String chatId) {
    ischatFetchLoading.value = true;
    print('채팅방 입장 요청 보냄');
    print(chatId);
    socket?.emit('joinChat_doctor', chatId);

    ischatFetchLoading.value = false;
    //socket?.on('joinChat_user', (data) { print(data);} );
  }

  Future<void> leaveChat(String chatId) async {
    print('채팅방 퇴장 요청 보냄');
    socket?.emit('leaveChat_doctor', chatId);
  }

  //유저측 전송
  void sendMessage(String chatId, String message) {
    print('chatId: $chatId');
    print('메시지 전송: $message');
    socket?.emit('sendChat_doctor', json.encode({'roomNo': chatId, 'message': message}));
    //socket?.emit('sendChat_doctor', {'roomNo': chatId, 'message': message});
    //socket?.emit('sendChat', {'roomNo': chatId, 'message': message});
  }

  void sendAppointmentRefresh(String chatId) {
    print('send REFRESH REQUEST');
    socket?.emit('appointmentRefresh', json.encode({'roomNo': chatId}));
  }

  void onAppointmentApproval(Function callback) {
    socket?.on('appointmentApproval', (data) => callback(data));
  }



}
*/
