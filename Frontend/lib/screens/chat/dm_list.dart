import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/Database/chat_database.dart';
import 'package:to_doc/auth/auth_secure.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/screens/chat/chat_screen.dart';
import 'package:to_doc/screens/intro.dart';
import 'package:to_doc/socket_service/chatlist_socket_service.dart';
import 'package:to_doc/main.dart';

class DMList extends StatefulWidget {
  DMList({required this.controller});

  final ChatController controller;

  @override
  State<DMList> createState() => _DMListState();
}

class _DMListState extends State<DMList> with WidgetsBindingObserver, RouteAware {

  late ChatListSocketService chatListSocketService;
  bool isFirstLoading = false;
  final ChatDatabase chatDb = ChatDatabase();
  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
}
  void socketConnection() async{
    SecureStorage storage = SecureStorage(storage: FlutterSecureStorage());
    String? token = await storage.readAccessToken();

    if (token == null) {
      print('TOKEN ERROR ----------- [NULL ACCESS TOKEN]');
      Get.offAll(() => Intro());
    }

    print(token);
    chatListSocketService = ChatListSocketService(token!, onConnected: () {
      print("채팅 리스트용 소켓이 성공적으로 연결되었습니다!");
      // setState(() {
      //   isSocketConnected = true;
          
      // });

    });
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatListSocketService.onEventOccurred((data) {
        print('event occurred');
        print(data);
        
        if (this.mounted) {

          widget.controller.getChatList();
        
        }
      });
    });


  }
  void goToChatScreen(chat) async {
    print("최신 id: ${chat.cid}");

    int lastAutoIncrementID;
    lastAutoIncrementID = await chatDb.getLastReadId(chat.cid);
    print("마지막 id: $lastAutoIncrementID");

    int unread = chat.recentChat['autoIncrementId'] - lastAutoIncrementID;

    print('안읽은 개수: ${unread}');
    //print('lastreadid: ${widget.controller.lastReadId}');
    await widget.controller.enterChat(chat.cid, lastAutoIncrementID);
    //widget.controller.enterChat(chat.cid, chat.recentChat['autoIncrementId']);

    Get.to(()=> ChatScreen(doctorId: chat.doctorId, chatId: chat.cid, unreadMsg: unread, doctorName: chat.doctorName,autoIncrementId: chat.recentChat['autoIncrementId']));
  }

  //  @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state == AppLifecycleState.paused) {
  //     chatListSocketService.onDisconnect();
      
  //     print("DmList 백그라운드 전환: SocketDisconnect");
  //   }
  // }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   //Todo: DMList안에서만 socket연결, 벗어나면 무조건 disconnect하기기
  //   //route.subscribe(this, ModalRoute.of(context)! as PageRoute);
  // }
  @override
  void didPushNext() {
    print("DMList에서 다른 페이지로 이동 중이므로 소켓 연결 해제");
    chatListSocketService.onDisconnect();
  }
  @override
  void didPopNext() {
    print("DMList로 돌아왔으므로 소켓 재연결");
    socketConnection();
  }



  @override
  void initState() {
    super.initState();
    socketConnection();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          widget.controller.getChatList();
        });
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    chatListSocketService.onDisconnect();
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
      body: Obx(() {
        if (widget.controller.isLoading.value && !isFirstLoading) {
          isFirstLoading = true;
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.controller.chatList.isEmpty) {
          return const Center(child: Text('채팅 내역이 없습니다.'));
        }

        return ListView.builder(
          itemCount: widget.controller.chatList.length,
          itemBuilder: (context, index) {
            final chat = widget.controller.chatList[index];
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
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        child: Image.network(chat.profilePic, scale: 20,)
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.doctorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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


                   Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Text(
                         formattedDate,
                         style: TextStyle(
                           fontSize: 12,
                           color: Colors.grey.shade600,
                         ),
                       ),
                       SizedBox(height: 5,),

                       FutureBuilder<int>(
                          future: chatDb.getLastReadId(chat.cid),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }
                            print(chat.cid);
                            int lastAutoIncrementID = snapshot.data!;
                            print(lastAutoIncrementID);
                            int unread = chat.recentChat['autoIncrementId'] - lastAutoIncrementID;
                            if (unread > 0) {
                              return Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$unread',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                     ],
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
