import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:to_doc/controllers/aichat_controller.dart';
import 'package:to_doc/controllers/aichat_save_coltroller.dart';

import 'chat_bubble_listview.dart';
import 'chat_socket_service.dart';
import 'chat_object.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:bubble/bubble.dart';


class AiChatSub extends StatefulWidget {
  final List<ChatObject> messageList;

  const AiChatSub({Key? key, required this.messageList}) : super(key: key);

  @override
  State<AiChatSub> createState() => _AiChatSub(messageList);
}

class _AiChatSub extends State<AiChatSub> with WidgetsBindingObserver {
  AiChatController aiChatController = Get.put(AiChatController());
  AiChatSaveController aiChatSaveController = Get.put(AiChatSaveController());
  TextEditingController textEditingController = Get.put(TextEditingController());
  final scrollController = ScrollController();

  var chatId = '';
  List<ChatObject> _messageList = [];
  late ChatSocketService socketService;

  _AiChatSub(List<ChatObject> messageList) {
    _messageList = messageList;
  }

  void asyncNew() async {
    await aiChatController.getNewChat();

    setState(() {
      _messageList.add(
          ChatObject(content: aiChatController.firstChat, role: 'ai', createdAt: DateTime.now()));
      scrollController.animateTo(0, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
    });

    socketService = ChatSocketService(aiChatController.chatId);

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      socketService.onChatReceved((data) {
        print('CALL BACK SUCCESS');
        setState(() {
          _messageList.add(
              ChatObject(content: data, role: 'ai', createdAt: DateTime.now()));
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    asyncNew();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        await aiChatSaveController.saveChat(aiChatController.chatId);
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            centerTitle: true,
            title: InkWell(
              onTap: () {
                /*to about page*/
              },
              child: Text('토닥toDoc',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
          ),

          body:
          Padding(padding: EdgeInsets.all(10),
            child: Column(
              children: [
                ChatMaker(scrollController: scrollController, messageList: _messageList,),
                Row(
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
                ),
              ]
            )
          )
      ),
    );
  }


  void _handleSubmitted(String text) {
    print(text);

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
  }
}



