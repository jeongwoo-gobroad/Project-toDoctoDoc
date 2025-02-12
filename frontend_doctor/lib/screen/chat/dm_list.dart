import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/Database/chat_database.dart';

import '../../controllers/chat_controller.dart';
import 'chat_screen.dart';

class DMList extends StatefulWidget {
  const DMList({super.key});

  @override
  State<DMList> createState() => _DMListState();
}

class _DMListState extends State<DMList> {
  final ChatDatabase chatDb = ChatDatabase();
  final ChatController controller = Get.put(ChatController());
  
  void goToChatScreen(chat) async {
    //linkTest();

    int lastAutoIncrementID;
    lastAutoIncrementID = await chatDb.getLastReadId(chat.cid);

    int unread = chat.recentChat['autoIncrementId'] - lastAutoIncrementID;
    print('lastID : $lastAutoIncrementID');
    print('안읽은 개수: ${unread}');
    await controller.enterChat(chat.cid, lastAutoIncrementID);

    Get.to(()=> ChatScreen(
      chatId: chat.cid,
      unreadChat: unread,
      userName: '',//chat.userName,
      userId: chat.userId,
    ))?.whenComplete(() {
      if(this.mounted){
        setState(() {
          
          controller.getChatList();
          
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          controller.getChatList();
        });

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('채팅 목록'),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   elevation: 0,
      // ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.chatList.isEmpty) {
          return const Center(child: Text('채팅 내역이 없습니다.'));
        }

        return ListView.builder(
          itemCount: controller.chatList.length,
          itemBuilder: (context, index) {
            final chat = controller.chatList[index];
            final formattedDate = DateFormat('MM/dd HH:mm').format(chat.date.toLocal());

            return InkWell(
              onTap: () {
                goToChatScreen(chat);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [

                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                chat.userName ?? '유저 이름 없음',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(chat.recentChat['role'] == 'doctor') ? '나' : chat.userName}: ${chat.recentChat['message']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<int>(
              future: chatDb.getLastReadId(chat.cid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                int lastAutoIncrementID = snapshot.data!;
                int unread = chat.recentChat['autoIncrementId'] - lastAutoIncrementID;
                if (unread > 0) {
                  return Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
