import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_bubble_listview.dart';
import 'controllers/aichat_load_controller.dart';
import 'package:to_doc/chat_object.dart';


class AiChatOldView extends StatefulWidget {
  const AiChatOldView({Key? key, required this.chatId}) : super(key:key);

  final String chatId;

  @override
  State<AiChatOldView> createState() => _AiChatOldViewState(chatId);
}

class _AiChatOldViewState extends State<AiChatOldView> {
  AichatLoadController  aichatLoadController = Get.put(AichatLoadController());
  get scrollController => null;
  String chatid = '';
  var _messageList;

  _AiChatOldViewState(String chatId) {
    chatid = chatId;
    print('into Chat');
    print(chatId);
  }

  void asyncNew() async {
    await aichatLoadController.loadChat(chatid);
    _messageList = aichatLoadController.messageList;

    print(_messageList);
  }

    @override
  void initState() {
    super.initState();
    asyncNew();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

      body: Obx(() {
        if(aichatLoadController.isLoading.value){
          return Center(child: CircularProgressIndicator());
        }
        return
          Padding(padding: EdgeInsets.all(10),
            child: Column(
              children: [ChatMaker(scrollController: scrollController, messageList: _messageList,),],
            ),
          );
        }),
    );
  }
}
