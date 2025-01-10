import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class ChatTest extends StatefulWidget {
  const ChatTest({super.key});

  @override
  State<ChatTest> createState() => _ChatTestState();
}

class _ChatTestState extends State<ChatTest> {
  socket_io.Socket? socket;
  
  
  @override
  void initState() {
    
    super.initState();
    _initSocket();
  }
  @override
  void dispose() {
    socket?.close();
    super.dispose();
  }

  Future<void> _initSocket() async {
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
            .build()
      );

      // socket 연결 성공 여부 확인
      socket?.onConnect((_) {
        print('Socket 연결 성공');
      });

      socket?.onError((error) {
        print('Socket 에러: $error');
      });

      socket?.on('connection::chatList', (data) {
      print('받은 채팅 리스트:');
      print(json.decode(data));

    });
    } catch (e) {
      print('Socket 초기화 에러: $e');
      Get.snackbar('Error', '연결 중 오류가 발생했습니다.');
    }
  }
  void _fetchChatList(){
    print('채팅 리스트 요청 보냄');
    socket?.emit('connection::chatList', null); // DM 리스트 요청
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(

        child: Row(
          children: [
            ElevatedButton(
              onPressed: (){_fetchChatList();}, 
              child: Text('chatlist'),
            ),
            ElevatedButton(
              onPressed: (){}, 
              child: Text('chatlist'),
            ),
            ElevatedButton(
              onPressed: (){}, 
              child: Text('chatlist'),
            ),
            ElevatedButton(
              onPressed: (){}, 
              child: Text('chatlist'),
            ),
          ],







        ),
      ),

    );
  }
}