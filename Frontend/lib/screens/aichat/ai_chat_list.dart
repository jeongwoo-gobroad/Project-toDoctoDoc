import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_doc/aboutpage.dart';
import 'package:to_doc/controllers/aichat/aichat_delete_coltroller.dart';
import 'package:dio/dio.dart';

import '../../controllers/aichat/ai_chat_list_controller.dart';
import 'ai_chat_oldview.dart';
import 'ai_chat_screen.dart';

enum MenuType {
  edit(tostring: 'temp', toIcon: Icon(CupertinoIcons.scissors)),
  delete(tostring: 'delete', toIcon: Icon(Icons.phonelink_erase));

  final String tostring;
  final Icon toIcon;
  const MenuType({required this.tostring, required this.toIcon});
}

class AiChatList extends StatefulWidget {
  const AiChatList({super.key});

  @override
  State<AiChatList> createState() => _AiChatListState();
}

class _AiChatListState extends State<AiChatList> {
  AiChatListController aiChatListController = Get.put(AiChatListController(dio: Dio()));
  AiChatDeleteController aiChatDeleteController = Get.put(AiChatDeleteController(dio: Dio()));

  void asyncLoad() async {
    await aiChatListController.getChatList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    asyncLoad();
  }
  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date);

    String formattedDate;

    if (dateTime.day == DateTime.now().day) {
      formattedDate = DateFormat('HH:mm').format(dateTime);
    }
    else {
      formattedDate = DateFormat('yyyy.M.d.').format(dateTime);
    }
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body :
        Column (
          children: [Expanded(
            child: Obx(() {
              if (aiChatListController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (aiChatListController.isEmpty.value) {
                return Center(
                  child:Text('채팅이 없습니다'),
                );
              }
              child:
              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(2.0),
                itemCount: aiChatListController.chatList.length,
                itemBuilder: (context, int index) {
                  final chatRoom = aiChatListController.chatList[index];
                  print(chatRoom['title']);
                  return GestureDetector(
                    onTap: () {
                      Get.to(()=> AiChatOldView(chatId: chatRoom['_id'], chatTitle: (chatRoom['title'] != null) ? chatRoom['title'] : '빈 제목',))?.whenComplete(() {
                        setState(() {
                          aiChatListController.getChatList();
                        });
                      });
                      print(chatRoom['_id']);
                    },

                    child: ListTile(
                      //minLeadingWidth : 1,
                      //horizontalTitleGap: 0.0,
                      trailing: Column(
                        children: [
                          PopupMenuButton<MenuType>(
                            onSelected: (MenuType result) {
                              if (result.tostring == 'delete') {
                                setState(() {
                                  _onDeleted(chatRoom['_id']);
                                });
                              }
                              print(result);},
                            itemBuilder: (BuildContext buildContext) {
                              return [
                                for (final value in MenuType.values)
                                  PopupMenuItem(value: value,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(value.tostring),
                                        value.toIcon,
                                      ],
                                    ),
                                  )
                              ];
                            },
                          ),
                        ],
                      ),


                      title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              //
                              SizedBox(
                                  width: MediaQuery.of(context).size.width - 160,
                                  child: Text('${chatRoom['title']}', overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold),)),
                              SizedBox(
                                  width: 50,
                                  child: Text(formatDate(chatRoom['chatEditedAt']) ?? '',style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100, color: Colors.grey),)),
                        ],
                      ),
                      subtitle: Text('${chatRoom['recentMessage']}', overflow: TextOverflow.ellipsis,),

                      //trailing: Text(formatDate(chatRoom['chatEditedAt']) ?? ''),
                    ),
                  );
                },
              );
            }),
          ),
          Container (
            //width:  ,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 225, 234, 205),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                minimumSize: const Size(double.infinity, 15),
                shape: BeveledRectangleBorder(),
                //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7),),
              ),
              onPressed: (){
                Get.to(()=> AiChatSub(isNewChat : true, chatId : '', messageList: [],))?.whenComplete(() {
                  setState(() { _onReload(); });
                });},

              child: Text('새 채팅 시작하기', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black),
              ),
            ),
          ),

          ]
        ),
    );
  }
  void _onReload() async{
    await aiChatListController.getChatList();
  }


  void _onDeleted(String chatId) async{
    print(chatId);
    aiChatListController.isLoading.value = true;
    await aiChatDeleteController.deleteOldChat(chatId);
    await aiChatListController.getChatList();
  }

}
