import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';
import 'package:to_doc_for_doc/screen/chat/dm_chat_list_maker.dart';
import 'package:to_doc_for_doc/screen/chat/upper_appointment_information.dart';

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
              return upperAppointmentInformation(appointmentController: appointmentController);
            }),

            Obx(() {
              if (widget.socketService.ischatFetchLoading.value && scrollLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return makeChatList(scrollController: _scrollController, messageList: _messageList, updateUnread: updateUnread,);

            }),

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

