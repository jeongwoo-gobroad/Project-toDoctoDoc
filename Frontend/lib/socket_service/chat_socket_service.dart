import 'dart:convert';
import 'package:get/get.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';

class ChatSocketService {
  //var chat = <Map<String, dynamic>>[].obs;
  var ischatFetchLoading = false.obs;

  late io.Socket socket;
  late var RoomCode;
  bool chatOngoing = false;

  var chatList;

  var chatMap;

  ChatSocketService(String token) {
    ischatFetchLoading = true.obs;

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
        ischatFetchLoading = true.obs;
        socket?.emit('chatList', null);
      });

      socket?.onError((error) {
        print('Socket 에러: $error');
      });

      socket?.onDisconnect((_) => print('Disconnected from server'));

      socket?.on('joinChat_user', (data) {
        print('채팅방 입장:');
        print(data);
      });

      socket?.on('returnChatList', (data) {
        print('받은 채팅 리스트:');

        print(data);
        //chatList = json.decode(data);

        //print('returnchatList');
        //print(chatList);
      });

      socket?.on('returnJoinedChat_doctor', (data) {
        print('test2 doctor');
        print(data);
      });


    } catch (e) {
      print('Socket 초기화 에러: $e');
      Get.snackbar('Error', '연결 중 오류가 발생했습니다.');
    }
  }

  void onAppointmentRefresh(Function callback) {
    print('test1 user');
    socket.on('appointmentRefresh', (data) =>callback(data));
  }


  void onReturnJoinedChat_user(Function callback) {
    print('test1 user');
    socket.on('returnJoinedChat_user', (data) =>callback(data));
  }

  void onUnread_doctor(Function callback) {
    socket.on('unread_doctor ', (data) =>callback(data));
  }

  void onReturnJoinedChat_doctor(Function callback) {
    socket.on('returnJoinedChat_doctor', (data) =>callback(data));
  }

  void onMsgListReceived(Function callback) {
    socket.on('chatList', (data) => callback(data));
  }

  void onUserReceived(Function callback) {
    socket.on('recvChat_user', (data) => callback(data));
    print('유저 메세지 수신');
  }
  void onDoctorReceivec(Function callback) {
    socket.on('recvChat_doctor', (data) =>callback(data));
    print('의사 메시지 수신:');
  }

  void joinChat(String chatId) {
    ischatFetchLoading.value = true;
    print('채팅방 입장 요청 보냄');
    print(chatId);
    socket.emit('joinChat_user', chatId);
    ischatFetchLoading.value = false;
  }

  Future<void> leaveChat(String chatId) async {
    print('채팅방 퇴장 요청 보냄');
    socket.emit('leaveChat_user', chatId);
  }

  //유저측 전송
  void sendMessage(String chatId, String message) {
    print('chatId: $chatId');
    print('메시지 전송: $message');
    socket?.emit('sendChat_user', json.encode({'roomNo': chatId, 'message': message}));
  }

  void sendAppointmentApproval(String chatId) {
    print('chatId: $chatId');
    socket?.emit('appointmentApproval', json.encode({'roomNo': chatId}));
  }

}
