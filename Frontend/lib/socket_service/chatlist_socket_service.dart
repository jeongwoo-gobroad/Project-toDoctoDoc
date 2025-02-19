import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_doc/auth/auth_secure.dart';

class ChatListSocketService {
  //var chat = <Map<String, dynamic>>[].obs;
  var ischatFetchLoading = false.obs;

  late io.Socket socket;
  late var RoomCode;
  bool chatOngoing = false;

  var chatList;

  var chatMap;

  ChatListSocketService(String token, {Function? onConnected}) {
    ischatFetchLoading.value = true;

    try {
      socket = io.io(
          'http://jeongwoo-kim-web.myds.me:3000/dm_user_list',
          io.OptionBuilder()
              .setTransports(['websocket'])
              .setQuery({'token': token,})
              .setPath('/chatList')
              .enableAutoConnect()
              .enableForceNew()
              .disableReconnection()
              .build()
      );

      socket.onConnect((_) {
        print('Chat List용 Socket 연결 성공');
        
         if (onConnected != null) {
          onConnected();
        }
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


  void onEventOccurred(Function callback) {
    socket.on('newChatExists', (data) =>callback(data));
  }

  void onDisconnect() {
    print("ONDISCONNECT");
    socket.disconnect();
  }
}
