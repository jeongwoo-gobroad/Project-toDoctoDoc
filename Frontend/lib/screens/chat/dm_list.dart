import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/Database/chat_database.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/screens/chat/chat_screen.dart';

class DMList extends StatefulWidget {
  @override
  State<DMList> createState() => _DMListState();
}

class _DMListState extends State<DMList> {
  final ChatController controller = Get.put(ChatController(dio: Dio()));

  void goToChatScreen(chat) async {
    print(chat.chatId);

    Get.to(()=> ChatScreen(doctorId: chat.doctorId, chatId: chat.chatId, unreadMsg: chat.unreadChat, doctorName: chat.doctorName,))?.whenComplete(() {
      setState(() {
        controller.getChatList();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    if (!controller.isLoading.value) {
      controller.getChatList();
    }
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
                                chat.doctorName,
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
