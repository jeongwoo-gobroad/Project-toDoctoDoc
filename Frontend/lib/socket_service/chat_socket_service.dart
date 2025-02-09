import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_doc/auth/auth_secure.dart';

class ChatSocketService {
  //var chat = <Map<String, dynamic>>[].obs;
  var ischatFetchLoading = false.obs;

  late io.Socket socket;
  late var RoomCode;
  bool chatOngoing = false;

  var chatList;

  var chatMap;

  ChatSocketService(String token, String chatId) {
    ischatFetchLoading.value = true;

    try {
      socket = io.io(
          'http://jeongwoo-kim-web.myds.me:3000/dm_user',
          io.OptionBuilder()
              .setTransports(['websocket'])
              .setQuery({'token': token, 'roomNo': chatId,})
              .setPath('/msg')
              .enableAutoConnect()
              .enableForceNew()
              .disableReconnection()
              .build()
      );

      socket.onConnect((_) {
        print('Socket 연결 성공');
        ischatFetchLoading.value = false;
        socket.emit('chatList', null);
      });

      socket.onError((error) {
        print('Socket 에러: $error');
      });

      socket.onDisconnect((_) => print('Disconnected from server'));

    } catch (e) {
      print('Socket 초기화 에러: $e');
      Get.snackbar('Error', '연결 중 오류가 발생했습니다.');
    }
  }


  //유저측 송 / 수신
  void sendMessage(String message) {
    print("SEND MESSAGE : $message");
    socket.emit('SendChat', message);
  }
  void onUserReceived(Function callback) {
    socket.on('chatReceivedFromServer', (data) =>callback(data));
  }

  void onDisconnect() {
    print("ONDISCONNECT");
    socket.disconnect();
  }
}
