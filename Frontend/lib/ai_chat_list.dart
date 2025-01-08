import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/ai_chat_list_controller.dart';
import 'package:to_doc/aboutpage.dart';
import 'package:to_doc/controllers/aichat_delete_coltroller.dart';

import 'ai_chat_oldview.dart';

enum MenuType {
  edit(tostring: 'edit', toIcon: Icon(CupertinoIcons.scissors)),
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
  AiChatListController aiChatListController = Get.put(AiChatListController());
  AiChatDeleteController aiChatDeleteController = Get.put(AiChatDeleteController());

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
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: InkWell(
          onTap: () {
            /*to about page*/
            //Get.to(() => Aboutpage());
          },
          child: Text('Ai 채팅 목록',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
      ),

      body :
        Obx(() {
          if (aiChatListController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (aiChatListController.chatList.isEmpty) {
            return Center(
              child:Text('NO chat'),
            );
          }
          child:
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: aiChatListController.chatList.length,
            itemBuilder: (context, int index) {
              final chatRoom = aiChatListController.chatList[index];

              print(chatRoom['title']);
              return GestureDetector(
                onTap: () {
                  Get.to(()=> AiChatOldView(chatId: chatRoom['_id'],));
                  print(chatRoom['_id']);
                },

                child: ListTile(
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
                      Text('${chatRoom['title']}'),
                      Text(formatDate(chatRoom['chatEditedAt']) ?? '',style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100, color: Colors.grey),),
                    ],
                  ),
                  subtitle: Text('${chatRoom['recentMessage']}', overflow: TextOverflow.ellipsis,),

                  //trailing: Text(formatDate(chatRoom['chatEditedAt']) ?? ''),
                ),
              );
            },
          );
        }),
    );
  }

  void _onDeleted(String chatId) async{
    print(chatId);
    aiChatListController.isLoading.value = true;
    await aiChatDeleteController.deleteOldChat(chatId);
    await aiChatListController.getChatList();
  }

}
