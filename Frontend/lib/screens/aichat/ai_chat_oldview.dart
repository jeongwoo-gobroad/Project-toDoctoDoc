import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/aichat/aichat_load_controller.dart';
import 'chat_bubble_listview.dart';
import 'package:to_doc/chat_object.dart';
import 'ai_chat_screen.dart';
import 'package:dio/dio.dart';


class AiChatOldView extends StatefulWidget {
  const AiChatOldView({Key? key, required this.chatId, required this.chatTitle}) : super(key:key);

  final String chatTitle;
  final String chatId;

  @override
  State<AiChatOldView> createState() => _AiChatOldViewState(chatId);
}

class _AiChatOldViewState extends State<AiChatOldView> {
  AichatLoadController  aichatLoadController = Get.put(AichatLoadController(dio: Dio()));
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
          child: Text('${widget.chatTitle}', overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),

      body: Obx(() {
        if(aichatLoadController.isLoading.value){
          return Center(child: CircularProgressIndicator());
        }
        return
          Padding(padding: EdgeInsets.all(10),
            child: Column(
              children: [
                ChatMaker(scrollController: scrollController, messageList: _messageList,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      foregroundColor: const Color.fromARGB(255, 51, 51, 51),
                      minimumSize: const Size(double.infinity, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                  onPressed: (){
                    print('edit');
                    print(chatid);
                    Get.off(()=> AiChatSub(isNewChat: false, chatId: chatid, messageList: _messageList,));
                  },
                  child: Text('채팅 재개하기', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white),),
                ),
              ],
            ),
          );
        }),
    );
  }
}
