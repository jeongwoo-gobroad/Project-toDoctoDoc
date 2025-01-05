import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:to_doc/aboutpage.dart';
import 'package:provider/provider.dart';
import 'package:to_doc/controllers/aichat_controller.dart';
import 'package:to_doc/controllers/aichat_delete_coltroller.dart';
import 'package:to_doc/controllers/aichat_save_coltroller.dart';

import 'chat_socket_service.dart';
import 'chat_object.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:bubble/bubble.dart';


class AiChatSub extends StatefulWidget {
  const AiChatSub({Key? key}) : super(key: key);

  @override
  State<AiChatSub> createState() => _AiChatSub();
}

class _AiChatSub extends State<AiChatSub> with WidgetsBindingObserver {
  AiChatController aiChatController = Get.put(AiChatController());
  AiChatSaveController aiChatSaveController = Get.put(AiChatSaveController());
  AiChatDeleteController aiChatDeleteController = Get.put(
      AiChatDeleteController());
  TextEditingController textEditingController = Get.put(
      TextEditingController());

  //final scrollController = ScrollController();

  var chatId = '';
  final List<ChatObject> _messageList = [];
  late ChatSocketService socketService;
  final scrollController = ScrollController();

  void asyncNew() async {
    await aiChatController.getNewChat();

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
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          title: InkWell(
            onTap: () {
              /*to about page*/
              Get.to(() => Aboutpage());
            },
            child: Text('토닥toDoc',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save_alt_rounded),
              onPressed: () {
                aiChatSaveController.saveChat(aiChatController.chatId);
              },
            )
          ],
        ),

        body:
        Padding(padding: EdgeInsets.all(10),
            child: Column(
                children: [
                  Expanded(
                      child: Align( alignment: Alignment.topCenter,
                        child: ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: _messageList.length,
                          controller: scrollController,
                          itemBuilder: (_, int index) {
                              return Bubble(
                                nip: _messageList[_messageList.length-index-1].role == 'user' ? BubbleNip.rightBottom : BubbleNip.leftBottom,
                                alignment: _messageList[_messageList.length-index-1].role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                                color: _messageList[_messageList.length-index-1].role == 'user' ? Colors.black : Colors.white,

                                margin: const BubbleEdges.only(top: 8),
                                child: Text('${_messageList[_messageList.length-index-1].content}',
                                  style: TextStyle(fontSize: 15,
                                      color: _messageList[_messageList.length-index-1].role == 'user' ? Colors.white : Colors.black),),
                              );
                          },
                        ),
                      )
                  ),

                  Stack(
                      children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextField(
                                maxLines: null,
                                controller: textEditingController,
                                //onSubmitted: _handleSubmitted,
                                decoration: InputDecoration(labelText: 'chat'),
                              ),
                            ),
                          ),

                        Positioned(
                            bottom: 0, right: 0,
                            child: IconButton(
                                onPressed: () =>
                                    _handleSubmitted(
                                        textEditingController.text),
                                icon: Icon(Icons.send_rounded)))
                      ]
                  ),
                ]
            )
        )
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
