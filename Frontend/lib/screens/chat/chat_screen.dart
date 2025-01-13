import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_doc/screens/aichat/chat_bubble_listview.dart';
import 'package:to_doc/chat_object.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/socket_service/chat_socket_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.socketService, required this.chatId}) : super(key:key);
  final ChatSocketService socketService;
  final String chatId;

  @override
  State<ChatScreen> createState() => _ChatScreen();
}


class _ChatScreen extends State<ChatScreen> {
  final ChatController controller = Get.put(ChatController(dio: Dio()));
  final ScrollController _scrollController = ScrollController();

  List<ChatObject> _messageList = [];

  void asyncBefore() async {


    widget.socketService.onReturnJoinedChat((data) {
      print('chat List received');
      //final decodedData = json.decode(data);

      print(data['chatList']);

      //setState(() {
      for (var chat in data['chatList']) {
        //print(chat['message']);
        _messageList.add(ChatObject(content: chat['message'], role: chat['role'] == 'user' ? 'user' : 'doctor', createdAt:null));
      }
      //});

/*        for (var i in _messageList) {
        print('${i.content} ${i.role}');
      }*/

      print(_messageList.length);

      // 나갔다 들어왔을 때 마운트 오류 발생해 해결
      if (this.mounted) setState(() {});

    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.socketService.onUserReceived((data) {
        print('user chat received');
        print('data1');
        print(data);

        //final data2 = (data[0]);
        //print('data2');
        //print(data2);

        setState(() {
          _messageList.add(ChatObject(content: data['message'], role: 'doctor', createdAt: DateTime.now()));
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    asyncBefore();
  }

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

/*    void scrollToBottom() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    } */
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

    return PopScope(
      onPopInvokedWithResult:(didPop, result) async {
        if (widget.socketService.ischatFetchLoading.value) {
          return;
        }
        widget.socketService.leaveChat(widget.chatId);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('채팅'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            //ChatMaker(scrollController: _scrollController, messageList: _messageList),
            Expanded(

              child: Obx(() {
                if (widget.socketService.ischatFetchLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
      /*              WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollToBottom();
                });*/
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _messageList.length,
                  itemBuilder: (context, index) {
                    final chatList = _messageList[index];
                    final isUser = _messageList[index].role == 'user';
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
                                    _messageList[index].content,
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
                          widget.socketService.sendMessage(widget.chatId, value);
                          messageController.clear();
                          setState(() {
                            _messageList.add(ChatObject(content: value,
                                role: 'user',
                                createdAt: DateTime.now()));
                            print(_messageList);
                          });
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
                        widget.socketService.sendMessage(widget.chatId, messageController.text);
                        print(_messageList);

                        setState(() {
                          _messageList.add(ChatObject(content: messageController.text, role: 'user', createdAt: DateTime.now()));
                        });
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
      ),
    );
  }
}
