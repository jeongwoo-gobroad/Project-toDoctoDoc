import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/Database/chat_database.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/screens/chat/chat_screen.dart';

class DMList extends StatefulWidget {
  DMList({required this.controller});

  final ChatController controller;

  @override
  State<DMList> createState() => _DMListState();
}

class _DMListState extends State<DMList> {
  final ChatDatabase chatDb = ChatDatabase();

  void goToChatScreen(chat) async {
    print("최신 id: ${widget.controller.serverAutoIncrementId}");

    int lastAutoIncrementID;
    lastAutoIncrementID = await chatDb.getLastReadId(chat.cid);
    print("마지막 id: $lastAutoIncrementID");

    int unread = chat.recentChat['autoIncrementId'] - lastAutoIncrementID;

    print('안읽은 개수: ${unread}');
    //print('lastreadid: ${widget.controller.lastReadId}');
    await widget.controller.enterChat(chat.cid, lastAutoIncrementID);
    //widget.controller.enterChat(chat.cid, chat.recentChat['autoIncrementId']);

    Get.to(()=> ChatScreen(doctorId: chat.doctorId, chatId: chat.cid, unreadMsg: unread, doctorName: chat.doctorName,autoIncrementId: chat.recentChat['autoIncrementId']));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          widget.controller.getChatList();
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅 목록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (widget.controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.controller.chatList.isEmpty) {
          return const Center(child: Text('채팅 내역이 없습니다.'));
        }

        return ListView.builder(
          itemCount: widget.controller.chatList.length,
          itemBuilder: (context, index) {
            final chat = widget.controller.chatList[index];
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
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        child: Image.network(chat.profilePic, scale: 20,)
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.doctorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(chat.recentChat['role'] == 'doctor') ? chat.doctorName : '나'}: ${chat.recentChat['message']}',
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


                   Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Text(
                         formattedDate,
                         style: TextStyle(
                           fontSize: 12,
                           color: Colors.grey.shade600,
                         ),
                       ),
                       SizedBox(height: 5,),

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
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$unread',
                                  style: const TextStyle(
                                    fontSize: 13,
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
