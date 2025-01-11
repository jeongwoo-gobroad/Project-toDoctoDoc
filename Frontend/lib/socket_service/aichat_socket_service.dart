import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';

class AiChatSocketService {
  late io.Socket socket;
  late var RoomCode;
  bool chatOngoing = false;

  AiChatSocketService(String chatRoomCode, String token) {
    //final prefs = SharedPreferences.getInstance();
    //final token = prefs.getString('jwt_token');

    chatOngoing = true;

    print("START SOCKET");
    print(chatRoomCode);

    RoomCode = chatRoomCode;

    socket = io.io('http://jeongwoo-kim-web.myds.me:3000/aichat',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setQuery({'chatid' : RoomCode, 'token' : token})
            .setPath('/msg')
            .enableForceNew()
            .build());
    socket.connect();

    socket.onConnect((_) {
      print('연결됨');
    });

    //socket.on('error', (error) => print('Connect error: $error'));

    //socket.emit('aichat', 'test');
    //socket.emitWithAckAsync('aichat', '테스트', ack: (response) {
    //  print('응답');});

    print('소켓 연결 완료');
  }


  void sendChat(String chatData) {
    print(chatData);
    socket.emit('aichat', chatData);
    //socket.on('aichat', (data) { print(data);} );
  }

  void onChatReceived(Function callback) {
    socket.on('aichat', (data) =>callback(data));
    /*
    {
      print('!!');
      print('message from server: $data');
    }/* => data(callback)*/);

     */
    //print('Return');
    print(callback);
  }

  void onDisconnect() {
    socket.onDisconnect((_) => print('disconnect'));
    chatOngoing = false;
  }
}