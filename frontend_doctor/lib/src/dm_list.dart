import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_controller.dart';
import 'chat_screen.dart';
import 'chat_socket_service.dart';


class DMList extends StatefulWidget {

  @override
  State<DMList> createState() => _DMListState();
}

class _DMListState extends State<DMList> {
  final ChatController controller = Get.put(ChatController(dio: Dio()));
  late ChatSocketService socketService;

  void startsocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }

    socketService = await ChatSocketService(token);
  }

  @override
  void initState() {
    super.initState();
    startsocket();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    socketService.socket?.dispose();
    socketService.socket?.disconnect();
    super.dispose();
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
      body: FutureBuilder(
        future: controller.getChatList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Obx(() {
            if (controller.chatList.isEmpty) {
              return const Center(child: Text('채팅 내역이 없습니다.'));
            }

            return ListView.builder(
              itemCount: controller.chatList.length,
              itemBuilder: (context, index) {
                final chat = controller.chatList[index];
                final lastMessage = chat.chatList.isNotEmpty
                    ? chat.chatList.last.message
                    : '메시지가 없습니다.';
                final formattedDate = DateFormat('MM/dd HH:mm')
                    .format(chat.date.toLocal());

                return InkWell(
                  onTap: () {
                    print(chat.id);
                    socketService.joinChat(chat.id);
                    Get.to(()=> ChatScreen(socketService: socketService, chatId: chat.id));

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
                                    chat.user.name ?? '의사 이름 없음',
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
                                lastMessage ?? "",
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
          });
        },
      ),
    );
  }
}
