import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';
import 'package:to_doc_for_doc/controllers/chat_appointment_controller.dart';
import 'package:to_doc_for_doc/controllers/chat_controller.dart';
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
  late ChatAppointmentController chatAppointmentController = Get.put(ChatAppointmentController(userId: widget.userId, chatId: widget.chatId));
  final AppointmentController appointmentController = Get.put(AppointmentController());
  ChatController chatController = Get.put(ChatController());
  late ChatSocketService socketService;
  bool _showScrollToBottom = false;
  ChatDatabase chatDb = ChatDatabase();
  RxBool isLoading = true.obs;

  late int updateUnread;
  late String appointmentId;
  int selectColor = 0;
  List<ChatObject> _messageList = [];
  RxBool isParsing = false.obs;

  alterParent() { setState(() {}); }
  Future<List<ChatObject>> parseChats(List<dynamic> chatsJson) async {
  List<ChatObject> messages = [];
  for (var chatData in chatsJson) {
    DateTime time;
    var tempTime = chatData['createdAt'];
    if (tempTime is String) {
      time = DateTime.parse(tempTime).toLocal();
    } else {
      time = DateTime.fromMillisecondsSinceEpoch(tempTime);
    }
    messages.add(ChatObject(
      content: chatData['message'],
      role: chatData['role'],
      createdAt: time,
    ));
  }
  _messageList.addAll(messages);
  return messages;
}

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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('취소', style: TextStyle(color:Colors.grey),),
            ),
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
  void parseAndStoreChats() async {
    isParsing.value = true;
    print('parseAndStore');
    List<dynamic> chatsJson = chatController.chatContents;
    List<ChatObject> parsedMessages = await compute(parseChats, chatsJson);
    for (var chat in parsedMessages) {
    chatDb.saveChat(
      widget.chatId,
      widget.userId,
      chat.content,
      chat.createdAt!,
      chat.role,
    );
    isParsing.value = false;
    // for (var chatData in chatsJson) {
    //   DateTime time;
    //   var tempTime = chatData['createdAt'];

    //   if(tempTime is String){
    //     time = DateTime.parse(chatData['createdAt']).toLocal();
    //   }
    //   else{
    //     time = DateTime.fromMillisecondsSinceEpoch(tempTime);
    //   }
      
    //   // messageList에 추가
    //   _messageList.add(
    //     ChatObject(
    //       content: chatData['message'],
    //       role: chatData['role'],
    //       createdAt: time.toLocal()
    //     )
    //   );
    //   chatDb.saveChat(widget.chatId, widget.userId, chatData['message'], time, chatData['role']);
    // }
  }
  }
  void animateToBottom(){
    Future.delayed(Duration(milliseconds: 100), () {
          if(!mounted) return;
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
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
        //print(chat);
        _messageList.add(ChatObject(content: chat['message'], role: chat['role'], createdAt: DateTime.parse(chat['timestamp']).toLocal()));
      }
    }

    if(widget.unreadChat != 0){
      print('parse: ${widget.unreadChat}');
      parseAndStoreChats();
    }

    if(this.mounted){
      setState(() {
        Future.delayed(Duration(milliseconds: 100), () {
          if(!mounted) return;
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
         if (!mounted) return;
        print('user chat received');
        print('data1');
        print(data);
        Map<String, dynamic> chatData;
        chatData = json.decode(data);
        var tempTime = chatData['createdAt'];
        final role = chatData['role'];
        DateTime time = DateTime.fromMillisecondsSinceEpoch(tempTime);

        if (this.mounted) {
          setState(() {
            _messageList.add(ChatObject(content: chatData['message'], role: role, createdAt: time.toLocal()));
            chatDb.saveChat(widget.chatId, widget.userId, chatData['message'], time, role);

            Future.delayed(Duration(milliseconds: 100), () {
               if (!mounted) return; 
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
    _scrollController.addListener(() {
      if (_scrollController.offset < _scrollController.position.maxScrollExtent - 100) {
        if (!_showScrollToBottom) {
          setState(() {
            _showScrollToBottom = true;
          });
        }
      } else {
        if (_showScrollToBottom) {
          setState(() {
            _showScrollToBottom = false;
          });
        }
      }
    });
    isLoading.value = false;
  }

  @override
  void dispose() {
    socketService.onDisconnect();
    _scrollController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  setAppointmentDay() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return AppointmentBottomSheet(
          userName: widget.userName,
          alterParent : alterParent,
        );
      },
    );
  }

  Widget _buildColorButton(Color color, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectColor = index;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectColor == index
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }

  Future<void> showMemoDialog(BuildContext context) async {
    final memoController = TextEditingController();
    final characterCount = ValueNotifier<int>(0);
    
    memoController.addListener(() {
      characterCount.value = memoController.text.length;
      if(characterCount.value > 500){}
    });
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '메모하기',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColorButton(Colors.red, 0),
                    _buildColorButton(Colors.orange, 1),
                    _buildColorButton(Colors.yellow, 2),
                    _buildColorButton(Colors.green, 3),
                    _buildColorButton(Colors.blue, 4),
                    _buildColorButton(Colors.purple, 5),
                    _buildColorButton(Colors.brown, 6),
                  ],
                ),
                SizedBox(height: 20,),

                Expanded(
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: memoController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                        decoration: const InputDecoration(
                          hintText: '메모를 입력하세요 (최대 500자)',
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: ValueListenableBuilder<int>(
                          valueListenable: characterCount,
                          builder: (context, count, child) {
                            return Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$count자 / 500',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('취소'),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(backgroundColor: Color.fromARGB(255, 225, 234, 205)),
                      onPressed: () {
                        //exists한지부터 판단하고 
                        if (memoController.text.isNotEmpty) {
                          
                          //서버로 보내기

                          print('메모 내용: ${memoController.text}');
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '확인',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

      // setState(() {
      //   _messageList.add(ChatObject(content: value,
      //       role: 'doctor',
      //       createdAt: DateTime.now()));

      //   DateTime now = DateTime.now().toUtc();
      //   chatDb.saveChat(widget.chatId, widget.userId, value, now, 'doctor');

      //   print(_messageList);
      // });

      // Future.delayed(Duration(milliseconds: 100), () {
      //   _scrollController.animateTo(
      //     _scrollController.position.maxScrollExtent,
      //     duration: Duration(milliseconds: 300),
      //     curve: Curves.easeOut,
      //   );
      // });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName, style: TextStyle(fontWeight: FontWeight.bold),),
        //centerTitle: true,
        shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(
                      widget.userName,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  // Text(
                  //   'ID: ${widget.userId}',
                  //   style: TextStyle(
                  //     color: Colors.white70,
                  //     fontSize: 14,
                  //   ),
                  // ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('메모모'),
              onTap: () {
                
                Navigator.pop(context);
                showMemoDialog(context); 
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('약속 관리'),
              onTap: () async {
/*                if (chatAppointmentController.isAppointmentExisted.value && chatAppointmentController.appointmentTime.value.isBefore(DateTime.now())) {
                  await appointmentMustBeDoneAlert(context);
                }
                setAppointmentDay();
                Navigator.pop(context);*/
              },
            ),
            ListTile(
              leading: Icon(Icons.block),
              title: Text('차단하기'),
              onTap: () {
                
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('나가기'),
              onTap: () {
                
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      
      
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          await chatController.getChatList();
          print('popped: ${chatController.serverAutoIncrementId}');
          await chatDb.updateLastReadId(widget.chatId, chatController.serverAutoIncrementId.value);
          socketService.onDisconnect();
        },
        child: Stack(
          children: [
            Column(
              children: [
                Obx(() {
                  if (chatAppointmentController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return UpperAppointmentInformation(chatId: widget.chatId);
                }),
                Expanded(
                  child: Obx(() {
                    if (isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return makeChatList(
                      messageList: _messageList,
                      scrollController: _scrollController,
                      updateUnread: updateUnread,
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
                          borderSide: BorderSide(width: 0, style: BorderStyle.none)),
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
                        icon: Icon(Icons.arrow_circle_right_outlined, size: 45),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showScrollToBottom)
            Positioned(
              bottom: 85,
              right: 20,
              child: GestureDetector(
                onTap: animateToBottom,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 211, 211, 211),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: Icon(Icons.arrow_downward, color: Colors.black),
                ),
              ),
            ),



            //파싱작업때 중앙로딩딩
            Obx(() => isParsing.value
                ? Container(
                    color: const Color.fromARGB(255, 234, 232, 232),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SizedBox()),
          ],
        ),
      ),
    );
  }
}

