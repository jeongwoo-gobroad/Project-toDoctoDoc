import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final ChatController controller = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();

  ChatScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    void scrollToBottom() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    } 
    // 
    // String getFormattedTime(String? timestamp) {
    //   if (timestamp == null) return '';
    //   try {
    //     final dateTime = DateTime.parse(timestamp);
    //     final formatter = DateFormat('a h:mm', 'ko_KR');
    //     return formatter.format(dateTime);
    //   } catch (e) {
    //     return '';
    //   }
    // }

    // 추후 구현 같은 user 연속 챗 동일 시간시 마지막 챗만 시간뜨도록록 
    // bool shouldShowTime(int index) {
    //   if (index == controller.chat.length - 1) return true;

    //   final currentMsg = controller.chat[index];
    //   final nextMsg = controller.chat[index + 1];

    //   final currentRole = currentMsg['role'];
    //   final nextRole = nextMsg['role'];
    //   final currentDate = currentMsg['date'];
    //   final nextDate = nextMsg['date'];

    //   
    //   return currentRole != nextRole || currentDate != nextDate;
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.ischatFetchLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
               scrollToBottom();
              });
              return ListView.builder(
                controller: _scrollController,
                itemCount: controller.chat.length,
                itemBuilder: (context, index) {
                  final chatList = controller.chat[index];
                  final isUser = chatList['role'] == 'User';
                  final showTime = true;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        //상대방 표시시
                        if (!isUser) ...[
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey[300],
                            child: Icon(Icons.person, color: Colors.grey[600]),
                          ),
                          SizedBox(width: 8),
                        ],
                        
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Colors.blue[100]
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  chatList['message'],
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '메시지를 입력하세요',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        controller.sendMessage(chatId, value);
                        messageController.clear();
                        Future.delayed(Duration(milliseconds: 100), () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      controller.sendMessage(chatId, messageController.text);
                      messageController.clear();
                      Future.delayed(Duration(milliseconds: 100), () {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                    }
                  },
                  child: Text('전송'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
