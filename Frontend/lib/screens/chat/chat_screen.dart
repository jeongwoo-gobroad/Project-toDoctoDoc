import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:to_doc/chat_object.dart';
import 'package:to_doc/controllers/careplus/chat_appointment_controller.dart';
import 'package:to_doc/screens/chat/dm_chat_list_maker.dart';
import 'package:to_doc/screens/chat/upper_appointment_inform.dart';
import 'package:to_doc/socket_service/chat_socket_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.socketService, required this.chatId, required this.unreadMsg, required this.doctorName}) : super(key:key);
  final ChatSocketService socketService;
  final String chatId;
  final int unreadMsg;
  final String doctorName;

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> with WidgetsBindingObserver {
  late ChatAppointmentController chatAppointmentController;
  final ScrollController _scrollController = ScrollController();

  bool scrollLoading = true;

  late int updateUnread;
  late bool isAppointment;

  List<ChatObject> _messageList = [];

  void asyncBefore() async {
    widget.socketService.onReturnJoinedChat_user((data) {
      print('APPOINTMENT IS?');

      if (data['chat']['appointment'] != null) {
        var appointmentId = data['chat']['appointment'];
        print(appointmentId);
        chatAppointmentController.isAppointmentExisted = true;
        if (this.mounted) {
          setState(() {
            chatAppointmentController.getAppointmentInformation(widget.chatId);
          });
        }
        chatAppointmentController.isAppointmentDone = data['chat']['hasAppointmentDone'];
      } else {
        chatAppointmentController.isLoading.value = false;
      }

      print('chat List received');
      print(data['chat']['chatList']);

      updateUnread = (data['unread'] == -1) ? 0 : data['unread'];

      DateTime? chatTime;
      var chatList = data['chat'];

      for (var chat in chatList['chatList']) {
        chatTime = (chat['createdAt'] == null) ? null : DateTime.parse(chat['createdAt']).toLocal();
        _messageList.add(ChatObject(
            content: chat['message'],
            role: chat['role'] == 'user' ? 'user' : 'doctor',
            createdAt: chatTime));
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
        updateUnread = 0;
        print('user chat received');
        print('data1');
        print(data);
        if (this.mounted) {
          setState(() {
            _messageList.add(ChatObject(content: data['message'], role: 'doctor', createdAt: DateTime.now()));
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
      widget.socketService.onAppointmentRefresh((data) {
        print('on APPOINTMENT SET');
        if (this.mounted) {
          setState(() {
            chatAppointmentController.getAppointmentInformation(widget.chatId);
          });
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.socketService.onReturnJoinedChat_doctor((data) {
        if (this.mounted) {
          setState(() {
            print('onretrn doctor');
            updateUnread = 0;
          });
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.socketService.onUnread_doctor((data) {
        if (this.mounted) {
          setState(() {
            print('onunread');
            updateUnread++;
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    chatAppointmentController = ChatAppointmentController(widget.socketService, widget.chatId);
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
         _messageList.add(ChatObject(content: value, role: 'user', createdAt: DateTime.now()));
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
          title: Text(widget.doctorName, style: TextStyle(fontWeight: FontWeight.bold),),
          //centerTitle: true,
          shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
        ),
        body: Column(
          children: [

            // 약속 알람 //
            Obx(() {
              if (chatAppointmentController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return upperAppointmentInform(appointmentController: chatAppointmentController);
            }),

            // 채팅 리스트 //
            Obx(() {
              if (widget.socketService.ischatFetchLoading.value && scrollLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return makeChatList(messageList: _messageList, scrollController: _scrollController, updateUnread: updateUnread,);
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
          ],
        ),
      ),
    );
  }
}
