import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';

import '../../model/chat_object.dart';
import '../../socket_service/chat_socket_service.dart';
import 'appointmentBottomSheet.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key,
    required this.socketService,
    required this.chatId,
    required this.unreadMsg,
    required this.userId,
    required this.userName});

  final ChatSocketService socketService;
  final String chatId;
  final int unreadMsg;
  final String userId;
  final String userName;

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  late AppointmentController appointmentController;

  bool scrollLoading = true;

  late int updateUnread;
  late String appointmentId;

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
      print('APPOINTMENT IS?');

      if (data['chat']['appointment'] != null) {

        appointmentId = data['chat']['appointment'];
        print(appointmentId);
        appointmentController.isAppointmentExisted = true;
        appointmentController.getAppointmentInformation(appointmentId);

        if (data['chat']['hasAppointmentDone']) {
          appointmentController.isAppointmentDone = true;
        }

      } else {
        appointmentController.isLoading.value = false;
      }

      print('chat List received');
      print(data);

      if (data['unread'] == -1) {
        updateUnread = 0;
      } else {
        updateUnread = data['unread'];
      }

      DateTime? chatTime;
      var chatList = data['chat'];
      for (var chat in chatList['chatList']) {
        if (chat['createdAt'] == null) {
          chatTime = null;
        }
        else {
          chatTime = DateTime.parse(chat['createdAt']).toLocal();
        }
        _messageList.add(ChatObject(content: chat['message'], role: chat['role'] == 'doctor' ? 'doctor' : 'user', createdAt:chatTime));
      }

      print(_messageList.length);

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
      widget.socketService.onDoctorReceived((data) {
        print('user chat received');
        print('data1');
        print(data);

        if (this.mounted) {
          setState(() {
            _messageList.add(ChatObject(content: data['message'],
                role: 'user',
                createdAt: DateTime.now()));

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.socketService.onAppointmentApproval((data) {
        setState(() {
          appointmentController.isAppointmentApproved = true;
        });
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.socketService.onUnread_user((data) {
        print('user is unread');
        setState(() {
          updateUnread++;
        });
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.socketService.onReturnJoinedChat_user((data) {
        print('user is connected');
        setState(() {
          updateUnread = 0;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    appointmentController = AppointmentController(userId: widget.userId, chatId: widget.chatId, socketService: widget.socketService);
    updateUnread = widget.unreadMsg;
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
          title: Text(widget.userName, style: TextStyle(fontWeight: FontWeight.bold),),
          //centerTitle: true,
          shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
        ),
        body: Column(
          children: [

            Obx(() {
              if (appointmentController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
                ),
                width: double.infinity,
                height: (appointmentController.isAppointmentExisted)? 80 : 0,
                child: Column(
                  children: [
                    if (appointmentController.isAppointmentExisted) ...[
                      Text('약속이 존재합니다',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                      Text('${appointmentController.appointmentId} : 약속 ID',
                        style: TextStyle(fontSize: 10),),
                      Text('${appointmentController.appointmentTime}',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                      if (!appointmentController.isAppointmentApproved) ...[
                        Text('상대방이 아직 승낙하지 않았습니다.',
                          style: TextStyle(fontSize: 10, color: Colors.grey),),
                      ]
                      else ... [
                        Text('상대방이 약속을 승낙했습니다.',
                          style: TextStyle(fontSize: 10, color: Colors.grey),),
                      ],
                    ]
                  ],
                ),
              );

            }),

            Expanded(
              child: Obx(() {
                if (widget.socketService.ischatFetchLoading.value && scrollLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _messageList.length,
                  itemBuilder: (context, index) {
                    final isDoctor = _messageList[index].role == 'doctor';
                    final showTime = shouldShowTime(index);
                    final showDate = shouldShowDate(index);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 10.0,
                      ),
                      child: Column(
                        children: [
                          if (showDate) ... [
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
                                  if (index + updateUnread == _messageList.length - 1 &&
                                      isDoctor) ... [
                                    Container(
                                      padding: EdgeInsets.fromLTRB(0, 0, 12, 5),
                                      child: Text(
                                        '여기까지 읽음',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],

                                  if (isDoctor && showTime)...[
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

                              if (!isDoctor && showTime) ...[
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
                        setState(() {
                          setAppointmentDay();
                        });
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


  setAppointmentDay() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return AppointmentBottomSheet(
          userName: widget.userName,
          appointmentController: appointmentController,
        );
      },
    );
  }
}

