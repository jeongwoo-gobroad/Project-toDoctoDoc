import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatSocketService {
  final ischatFetchLoading = false.obs;

  late io.Socket socket;
  late var RoomCode;
  bool chatOngoing = false;

  ChatSocketService(String token, String chatId) {
    try {
      socket = io.io(
          'http://jeongwoo-kim-web.myds.me:3000/dm_doctor',
          io.OptionBuilder()
              .setTransports(['websocket'])
              .setQuery({'token': token, 'roomNo': chatId})
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

    } catch (e) {
      print('Socket 초기화 에러: $e');
      Get.snackbar('Error', '연결 중 오류가 발생했습니다.');
    }
  }

  void onDoctorReceived(Function callback) {
    socket?.on('chatReceived', (data) =>callback(data));
    print('의사 메시지 수신:');
  }

  //유저측 전송
  void sendMessage(String message) {
    print('메시지 전송: $message');
    socket?.emit('SendChat', message);
  }

}
