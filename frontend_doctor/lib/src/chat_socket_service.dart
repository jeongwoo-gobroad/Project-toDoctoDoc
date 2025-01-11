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


      //환자가 보낸 메시지 수신

      socket?.on('unread_user', (data) {
        print('unread doctor section');
        print(data);
      });

      /*
      socket?.on('returnChatList', (data) {
        print('받은 채팅 리스트:');
        print(data);
      });
*/

    } catch (e) {
      print('Socket 초기화 에러: $e');
      Get.snackbar('Error', '연결 중 오류가 발생했습니다.');
    }
  }

  void onReturnJoinedChat(Function callback) {
    socket?.on('returnJoinedChat', (data) => callback(data));
    /*
    {
      //chat.value = List<Map<String, dynamic>>.from(data['chatList']);
      ischatFetchLoading.value = false;
      //print(chat);
    });
*/
    print('받은 joinchat:');
    //print(data['chatList']);
  }

  void onMsgListReceived(Function callback) {
    socket?.on('chatList', (data) => callback(data));

/*    {
      final decodedData = json.decode(data);
      print(decodedData);
    });*/
  }

  void onUserReceived(Function callback) {
    socket?.on('recvChat_user', (data) => callback(data));

    print('유저 메세지 수신');
  }
  void onDoctorReceivec(Function callback) {
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

  void leaveChat(String chatId) {
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


}
