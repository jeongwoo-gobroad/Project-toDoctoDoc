import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_doc/auth/auth_secure.dart';
import 'package:to_doc/auth/login_test.dart';
import 'package:to_doc/controllers/aichat/aichat_controller.dart';
import 'package:to_doc/controllers/aichat/aichat_save_coltroller.dart';

import '../../chat_object.dart';
import '../../socket_service/aichat_socket_service.dart';
import 'chat_bubble_listview.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:bubble/bubble.dart';


class AiChatSub extends StatefulWidget {
  final List<ChatObject> messageList;
  final chatId;
  final bool isNewChat;

  const AiChatSub({Key? key, required this.isNewChat, required this.chatId, required this.messageList}) : super(key: key);

  @override
  State<AiChatSub> createState() => _AiChatSub();
}

class _AiChatSub extends State<AiChatSub> with WidgetsBindingObserver {
  AiChatController aiChatController = Get.put(AiChatController(dio: Dio()));
  AiChatSaveController aiChatSaveController = Get.put(AiChatSaveController(dio: Dio()));
  TextEditingController textEditingController = Get.put(TextEditingController());
  final scrollController = ScrollController();

  final SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());

  var chatId = '';
  List<ChatObject> _messageList = [];
  late AiChatSocketService socketService;

  void asyncNew() async {
    if (widget.isNewChat) {
      await aiChatController.getNewChat();
      chatId = aiChatController.chatId;
      _messageList.add(ChatObject(content: aiChatController.firstChat, role: 'ai', createdAt: DateTime.now()));
    }
    else {
      chatId = widget.chatId;
      _messageList = widget.messageList;
      print('inside');
      print(chatId);
      print(_messageList);
    }

    print(chatId);

    setState(() {

    });

    //final prefs = await SharedPreferences.getInstance();
    //final token = prefs.getString('jwt_token');

    final token = await storage.readAccessToken();
    if (token == null) {
      Get.snackbar('tokenError', '로그인 토큰 에러.');
      Get.offAll(()=> LoginPage());
    }

    socketService = AiChatSocketService(chatId, token!);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      socketService.onChatReceived((data) {
        print('CALL BACK SUCCESS');
        setState(() {
          _messageList.add(
              ChatObject(content: data, role: 'ai', createdAt: DateTime.now()));
          scrollController.animateTo(0, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
        });
      });
    });
    WidgetsBinding.instance!.ensureVisualUpdate();
  }

  @override
  void initState() {

    super.initState();
    asyncNew();
    aiChatController.chatLimit();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          if (aiChatController.isLoading.value) {
            //Get.snackbar('Error', '로딩 중에는 뒤로 갈 수 없습니다');
            return;
          }

          await aiChatSaveController.saveChat(chatId);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
              centerTitle: true,
              title: InkWell(
                onTap: () {
                  /*to about page*/
                },
                child: Text('Ai와의 채팅',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              //leading: ,
            ),

            body: 
            Padding(padding: EdgeInsets.all(10),
              child: Obx(()=>
                Column(
                  children: [
                    Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${aiChatController.userTotal.value} / ${aiChatController.chats.value}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                    ChatMaker(scrollController: scrollController, messageList: _messageList,),
                
                    TextField(
                      maxLines: null,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(100, 225, 234, 205),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide(width: 0, style: BorderStyle.none)
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        hintText: '메세지 입력',
                
                        suffixIcon: IconButton(
                            onPressed: () {_handleSubmitted(textEditingController.text);},
                            icon: Icon(Icons.arrow_circle_right_outlined, size: 45)
                        ),
                      ),
                    ),
                
                    /*Stack(
                      children: [
                        ConstrainedBox( constraints: BoxConstraints(maxHeight: 150,),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 90,
                              child: TextField(
                                maxLines: null,
                                controller: textEditingController,
                                //onSubmitted: _handleSubmitted,
                                decoration: InputDecoration(labelText: 'chat'),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: () => _handleSubmitted(textEditingController.text),
                            icon: Icon(Icons.send_rounded)
                          )
                        )
                      ]
                    ),*/
                  ]
                ),
              )
            )
        ),
      );
  }

  void _showQueryLimitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('채팅 사용 제한'),
        content: Text('오늘 사용 가능한 채팅 횟수를 모두 사용했습니다.'),
        actions: <Widget>[
          TextButton(
            child: Text('확인'),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      );
    },
  );
}
  void _handleSubmitted(String text) {
    print(text);
  
    if (aiChatController.isLimited.value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showQueryLimitDialog(context);
    });
  }
    if (text == '') {
      return;
    }
    textEditingController.clear();
    socketService.sendChat(text);

    setState(() {
      _messageList.add(
          ChatObject(content: text, role: 'user', createdAt: DateTime.now()));
      scrollController.animateTo(0, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
    });

    for (int i = 0; i < _messageList.length; i++) {
      print('${_messageList[i].content}, ${_messageList[i].role}');
    }

    aiChatController.chatLimit();
  if (aiChatController.isLimited.value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showQueryLimitDialog(context);
    });
  }
  }
}



