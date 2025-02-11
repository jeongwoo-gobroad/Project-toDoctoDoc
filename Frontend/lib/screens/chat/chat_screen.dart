import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:get/get.dart';
import 'package:to_doc/Database/chat_database.dart';
import 'package:to_doc/chat_object.dart';
import 'package:to_doc/controllers/careplus/chat_appointment_controller.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/screens/chat/dm_chat_list_maker.dart';
import 'package:to_doc/screens/chat/upper_appointment_inform.dart';
import 'package:to_doc/socket_service/chat_socket_service.dart';

import '../../auth/auth_secure.dart';
import '../intro.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.chatId, required this.unreadMsg, required this.doctorName, required this.doctorId, required this.autoIncrementId}) : super(key:key);
  final String chatId;
  final int unreadMsg;
  final String doctorName;
  final String doctorId;
  final int autoIncrementId;
  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> with WidgetsBindingObserver {
  late ChatAppointmentController chatAppointmentController = ChatAppointmentController();
  final ScrollController _scrollController = ScrollController();
  late ChatSocketService socketService;
  final ChatDatabase chatDb = ChatDatabase();
  final ChatController chatController = Get.put(ChatController());
  late int lastAutoIncrementID;
  RxBool isLoading = true.obs;

  late int updateUnread;
  late bool isAppointment;
  late int autoIncrement; 

  List<ChatObject> _messageList = [];

  animateToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
  void parseAndStoreChats() {

    print('parseAndStore');
    List<dynamic> chatsJson = chatController.chatContents;
    
    print(chatsJson);

     for (var chatData in chatsJson) {
      DateTime time;
      // DateTime 객체로 변환
      //DateTime messageTime = DateTime.parse(chatData['createdAt']);
      var tempTime = chatData['createdAt'];
      if(tempTime is String){
       time = DateTime.parse(chatData['createdAt']).toLocal();
      }
      else{
      time = DateTime.fromMillisecondsSinceEpoch(tempTime);
      }
      print('hello $chatData');
      // messageList에 추가
      _messageList.add(
        ChatObject(
          content: chatData['message'],
          role: chatData['role'],
          createdAt: time.toLocal()
        )
      );
      chatDb.saveChat(widget.chatId, widget.doctorId, chatData['message'], time, 'doctor');
    }
  
}
  void asyncBefore() async {
    SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());
    String? token = await storage.readAccessToken();

    if (token == null) {
      print('TOKEN ERROR ----------- [NULL ACCESS TOKEN]');
      Get.offAll(()=>Intro());
    }

    print(token);
    socketService = ChatSocketService(token!, widget.chatId);

    //채팅창 진입시 Db에서 마지막 id 불러옴
    //lastAutoIncrementID = await chatDb.getLastReadId(widget.chatId);

    //print('안 읽은 개수: ${widget.autoIncrementId - lastAutoIncrementID}');

    //updateUnread 전달달 widget.autoIncrementId - lastAutoIncrementId;

    //print('chat screen');
    var chatData = await chatDb.loadChat(widget.chatId);

    if (chatData != null) {
      print('NOT NULL');
      print(chatData);

      for (var chat in chatData) {
        print(chat);
        _messageList.add(ChatObject(content: chat['message'],
            role: chat['role'],
            createdAt: DateTime.parse(chat['timestamp']).toLocal()));
      }
    }
    //enterChat으로 받는 인자들 db에 삽입
    parseAndStoreChats();
    if (this.mounted) {
      setState(() {
        animateToBottom();
      });
    }


    // TODO 예전 채팅 폰에 저장된 거 불러 오기

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketService.onUserReceived((data) {
        updateUnread = 0;
        print('user chat received');
        print('data1');
        Map<String, dynamic> chatData;
        print('continue');
        print(data);
        chatData = json.decode(data);
        // if(chatData['role'] == 'user'){
          
        //   return;
        // }
        print(chatData['message']);
        var tempTime = chatData['createdAt'];
        final role = chatData['role'];
        DateTime time = DateTime.fromMillisecondsSinceEpoch(tempTime);

        if (this.mounted) {
          setState(() {
            _messageList.add(ChatObject(content: chatData['message'], role: role, createdAt: time.toLocal()));
            chatDb.saveChat(widget.chatId, widget.doctorId, chatData['message'], time, role);
          
            print('autoIncrement: $autoIncrement');
            animateToBottom();
          });
        }
      });
    });

  }



  @override
  void initState() {
    
    asyncBefore();
    super.initState();
    chatAppointmentController.getAppointmentInformation(widget.chatId);

    //최신id - 기존 id  
    updateUnread = widget.unreadMsg;
    autoIncrement = widget.autoIncrementId;
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

     void sendText(String value) {
       socketService.sendMessage(value);
       messageController.clear();

      //  setState(() {
      //    _messageList.add(ChatObject(content: value, role: 'user', createdAt: DateTime.now()));
      //    print(_messageList);
      //  });

      //  DateTime now = DateTime.now().toUtc();
      //  chatDb.saveChat(widget.chatId, widget.doctorId, value, now, 'user');
      //  animateToBottom();
     }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctorName, style: TextStyle(fontWeight: FontWeight.bold),),
        //centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
      ),
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          print('popping');
          await chatController.getChatList();
          await chatDb.updateLastReadId(widget.chatId, chatController.serverAutoIncrementId.value);
          socketService.onDisconnect();
        },
        child: Column(
          children: [

            // 약속 알람 //
            Obx(() {
              if (chatAppointmentController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return UpperAppointmentInform(appointmentController: chatAppointmentController, chatId: widget.chatId);
            }),

            // 채팅 리스트 //
            Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return makeChatList(messageList: _messageList, scrollController: _scrollController, updateUnread: updateUnread,);
            }),

            Padding(
              padding: const EdgeInsets.all(8.0),

              child: TextField(
                maxLines: null,
                controller: messageController,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    sendText(value);
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 244, 242, 248),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(width: 0, style: BorderStyle.none)
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  hintText: '메시지를 입력하세요',
                  suffixIcon: IconButton(
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          sendText(messageController.text);
                        }
                      },
                      icon: Icon(Icons.arrow_circle_right_outlined, size: 45)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
