import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../controllers/chat_controller.dart';
import '../../model/chat_object.dart';
import '../../socket_service/chat_socket_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.socketService, required this.chatId, required this.unreadMsg}) : super(key:key);
  final ChatSocketService socketService;
  final String chatId;
  final int unreadMsg;


  @override
  State<ChatScreen> createState() => _ChatScreen();
}


class _ChatScreen extends State<ChatScreen> with WidgetsBindingObserver {
  //final ChatController controller = Get.put(ChatController(dio: Dio()));
  final ScrollController _scrollController = ScrollController();

  bool scrollLoading = true;

  late int updateunread;
  late bool isAppointment;

  List<ChatObject> _messageList = [];

  String formatTime(DateTime? dateTime) {
    try {
      return DateFormat('aa hh:mm', 'ko_KR').format(dateTime!);
    } catch (e) {
      return '--:--';
    }
  }

  String formatDate(DateTime? dateTime) {
    try {
      return DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(dateTime!);
    } catch (e) {
      print(e);
      return '날짜 정보 없음';
    }
  }

  void asyncBefore() async {
    scrollLoading = true;

    widget.socketService.onReturnJoinedChat_doctor((data) {
      print('chat List received');
      print(data);
      print('sub');
      print(data['chat']['chatList']);

      if (data['unread'] == -1) {
        updateunread = 0;
      }
      else {
        updateunread = data['unread'];
      }

      DateTime? chatTime;
      var chatList = data['chat'];

      //setState(() {
      for (var chat in chatList['chatList']) {
        //print(chat['message']);

        if (chat['createdAt'] == null) {
          chatTime = null;
        }
        else {
          chatTime = DateTime.parse(chat['createdAt']).toLocal();
        }
        _messageList.add(ChatObject(content: chat['message'], role: chat['role'] == 'doctor' ? 'doctor' : 'user', createdAt:chatTime));
      }

      print(_messageList.length);

      // 나갔다 들어왔을 때 마운트 오류 발생해 해결
      if (this.mounted) {
        setState(() {
          Future.delayed(Duration(milliseconds: 50), () {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent * 2,
            );
          });
        });
      }
      scrollLoading = false;
    });

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.socketService.onUserReceived((data) {
        print('user chat received');
        print('data1');
        print(data);

        if (this.mounted) {
          setState(() {
            _messageList.add(ChatObject(content: data['message'], role: 'user', createdAt: DateTime.now()));

            Future.delayed(Duration(milliseconds: 100), () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            });
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    updateunread = widget.unreadMsg;
    asyncBefore();
  }

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    bool shouldShowTime(int index) {
      if (index == _messageList.length - 1) return true;

      final currentMsg = _messageList[index];
      final nextMsg = _messageList[index + 1];

      String currentTime = DateFormat('d HH mm').format(currentMsg.createdAt!);
      String nextTime = DateFormat('d HH mm').format(nextMsg.createdAt!);

      return currentMsg.role != nextMsg.role || currentTime != nextTime;
    }
    bool shouldShowDate(int index) {
      if (index == 0) {
        return true;
      }
      return _messageList[index].createdAt?.day != _messageList[index-1].createdAt?.day;
    }

    void sendText(String value) {
      widget.socketService.sendMessage(widget.chatId, value);
      messageController.clear();
      setState(() {
        updateunread++;

        _messageList.add(ChatObject(content: value,
            role: 'doctor',
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

    return PopScope(
      onPopInvokedWithResult:(didPop, result) async {
        if (widget.socketService.ischatFetchLoading.value) {
          return;
        }

        await widget.socketService.leaveChat(widget.chatId);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('DM', style: TextStyle(fontWeight: FontWeight.bold),),
          //centerTitle: true,
          shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
        ),
        body: Column(
          children: [
            Expanded(

              child: Obx(() {
                if (widget.socketService.ischatFetchLoading.value && scrollLoading) {
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
                    final isDoctor = _messageList[index].role == 'doctor';
                    final showTime = true;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      child: Column(
                        children: [
                          if (shouldShowDate(index)) ... [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                formatDate(_messageList[index].createdAt),
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],

                          Row(
                            mainAxisAlignment: isDoctor
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //상대방 표시시
                              if (!isDoctor) ...[
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(Icons.person, color: Colors.grey[600]),
                                ),
                                SizedBox(width: 8),
                              ],
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,

                                children: [
                                  if (index + updateunread == _messageList.length - 1 && isDoctor) ... [
                                    Container(
                                      padding: EdgeInsets.fromLTRB(0, 0, 12, 5),
                                      child: Text(
                                        '여기까지 읽음',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],

                                  if (isDoctor && shouldShowTime(index))...[
                                    Container(
                                      padding: EdgeInsets.fromLTRB(12, 0, 12, 5),
                                      child: Text(
                                        formatTime(_messageList[index].createdAt),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ]
                                ],),


                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isDoctor
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDoctor
                                            ? Color.fromARGB(255, 225, 234, 205)
                                            : Color.fromARGB(100, 244, 242, 248),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _messageList[index].content,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],),
                              ),

                              if (!isDoctor && shouldShowTime(index)) ...[
                                Container(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    formatTime(_messageList[index].createdAt),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],

                            ],),
                        ],),
                    );
                  },
                );
              }),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),

              child: TextField(
                maxLines: null,
                controller: messageController,

                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    sendText(value);
                  }
                },

                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(255, 244, 242, 248),

                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide(width: 0, style: BorderStyle.none)
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  hintText: '메시지를 입력하세요',

                  prefixIcon: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 500,
                              child: Column(
                                children: [
                                  Container(
                                    //height: 300,
                                    width: MediaQuery.of(context).size.width - 50,
                                    child: TableCalendar(
                                      locale: 'ko_KR',
                                      firstDay: DateTime.now(),
                                      lastDay: DateTime.utc(2030, 3, 14),
                                      focusedDay: DateTime.now(),
                                    ),
                                  ),

                                  Row(
                                    children:[
                                      TextButton(onPressed: () {}, child: Text('no')),
                                      TextButton(onPressed: () {}, child: Text('yes')),
                                    ]
                                  )

                                ],
                              ),
                            );
                          }
                        );

                      },
                      icon: Icon(Icons.edit_calendar_outlined),
                  ),

                  suffixIcon: IconButton(
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          sendText(messageController.text);
                        }
                      },
                      icon: Icon(Icons.arrow_circle_right_outlined, size: 45)
                  ),
                ),
              ),
            ),

          ],),
      ),
    );
  }



}
