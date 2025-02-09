import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';
import 'package:to_doc_for_doc/controllers/chat_appointment_controller.dart';
import 'package:to_doc_for_doc/screen/auth/login_screen.dart';
import 'package:to_doc_for_doc/screen/chat/dm_chat_list_maker.dart';
import 'package:to_doc_for_doc/screen/chat/upper_appointment_information.dart';

import '../../Database/chat_database.dart';
import '../../controllers/auth/auth_secure.dart';
import '../../model/chat_object.dart';
import '../../socket_service/chat_socket_service.dart';
import 'appointmentBottomSheet.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key,
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.unreadChat
  });

  final String chatId;
  final String userId;
  final String userName;
  final int unreadChat;

  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  late ChatAppointmentController chatAppointmentController = ChatAppointmentController(userId: widget.userId, chatId: widget.chatId);
  final AppointmentController appointmentController = AppointmentController();
  late ChatSocketService socketService;
  final ChatDatabase chatDb = ChatDatabase();

  RxBool isLoading = true.obs;

  late int updateUnread;
  late String appointmentId;

  List<ChatObject> _messageList = [];

  alterParent() { setState(() {}); }



  Future<void> appointmentMustBeDoneAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주의'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '새 약속을 잡기 위해선 이전 약속을 완료하거나 삭제해야 합니다.',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await chatAppointmentController.deleteAppointment()) {
                  // todo 삭제 완료 메세지 추가 필요
                  setState(() {});
                }

                Navigator.of(context).pop();
              },
              child: Text('약속 삭제', style: TextStyle(color:Colors.red),),
            ),
            TextButton(
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
              child: Text('완료 확정', style: TextStyle(color: Colors.white),),
              onPressed: () async {

                if (await appointmentController.sendAppointmentIsDone(chatAppointmentController.appointmentId)) {
                  Navigator.of(context).pop();
                  chatAppointmentController.isAppointmentDone.value = true;
                  setState(() {});
                }
                else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }


  void asyncBefore() async {
    isLoading.value = true;
    SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());
    String? token = await storage.readAccessToken();

    if (token == null) {
      print('TOKEN ERROR ----------- [NULL ACCESS TOKEN]');
      Get.offAll(()=>LoginPage());
    }

    print(token);
    print(widget.chatId);
    socketService = ChatSocketService(token!, widget.chatId);

    var chatData = await chatDb.loadChat(widget.chatId);

    if (chatData != null) {
      print('NOT NULL');
      print(chatData);

      for (var chat in chatData) {
        print(chat);
        _messageList.add(ChatObject(content: chat['message'], role: chat['role'], createdAt: DateTime.parse(chat['timestamp']).toLocal()));
      }
    }
    if(this.mounted){
    setState(() {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
    }

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketService.onDoctorReceived((data) {
        print('user chat received');
        print('data1');
        print(data);
        Map<String, dynamic> chatData;
        chatData = json.decode(data);
        var tempTime = chatData['createdAt'];
        DateTime time = DateTime.fromMillisecondsSinceEpoch(tempTime);

        if (this.mounted) {
          setState(() {
            _messageList.add(ChatObject(content: chatData['message'], role: 'user', createdAt: time.toLocal()));
            chatDb.saveChat(widget.chatId, widget.userId, chatData['message'], time, 'user');

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
    asyncBefore();
    updateUnread = widget.unreadChat;
    chatAppointmentController.getAppointmentInformation(widget.chatId);
    super.initState();
    isLoading.value = false;
  }

  setAppointmentDay() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return AppointmentBottomSheet(
          userName: widget.userName,
          chatAppointmentController: chatAppointmentController,
          alterParent : alterParent,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    void sendText(String value) {
      socketService.sendMessage(value);
      messageController.clear();

      setState(() {
        _messageList.add(ChatObject(content: value,
            role: 'doctor',
            createdAt: DateTime.now()));

        DateTime now = DateTime.now().toUtc();
        chatDb.saveChat(widget.chatId, widget.userId, value, now, 'doctor');

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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName, style: TextStyle(fontWeight: FontWeight.bold),),
        //centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
      ),
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          socketService.onDisconnect();
        },
        child: Column(
          children: [
            Obx(() {
              if (chatAppointmentController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return UpperAppointmentInformation(appointmentController: chatAppointmentController, chatId: widget.chatId,);
            }),


            Obx(() {
              if (isLoading.value) {
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
                        if (chatAppointmentController.isAppointmentExisted.value && chatAppointmentController.appointmentTime.value.isBefore(DateTime.now())) {
                          if (!chatAppointmentController.isAppointmentDone.value) {
                            appointmentMustBeDoneAlert(context);
                            return;
                          }
                        }
                        setAppointmentDay();
                        setState(() {});
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

