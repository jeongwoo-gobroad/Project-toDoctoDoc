import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/Database/chat_database.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_secure.dart';
import 'package:to_doc_for_doc/main.dart';
import 'package:to_doc_for_doc/screen/auth/login_screen.dart';
import 'package:to_doc_for_doc/socket_service/chatlist_socket_service.dart';

import '../../controllers/chat_controller.dart';
import 'chat_screen.dart';

class DMList extends StatefulWidget {
  const DMList({super.key});

  @override
  State<DMList> createState() => _DMListState();
}

class _DMListState extends State<DMList> with WidgetsBindingObserver, RouteAware {
  
  late ChatListSocketService chatListSocketService;
  bool isFirstLoading = false;
  final ChatDatabase chatDb = ChatDatabase();
  final ChatController controller = Get.put(ChatController());
  
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
      Get.offAll(()=>LoginPage());
    }

    print(token);
    chatListSocketService = ChatListSocketService(token!, onConnected: () {
      print("채팅 리스트용 소켓이 성공적으로 연결되었습니다!");
      
    });
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatListSocketService.onEventOccurred((data) {
        print('event occurred');
        print(data);
        
        if (this.mounted) {

          controller.getChatList();
        
        }
      });
    });


  }

  void goToChatScreen(chat) async {
    //linkTest();

    int lastAutoIncrementID;
    lastAutoIncrementID = await chatDb.getLastReadId(chat.cid);

    int unread = chat.recentChat['autoIncrementId'] - lastAutoIncrementID;
    print('lastID : $lastAutoIncrementID');
    print('안읽은 개수: ${unread}');
    await controller.enterChat(chat.cid, lastAutoIncrementID);

    Get.to(()=> ChatScreen(
      chatId: chat.cid,
      unreadChat: unread,
      userName: chat.userName,//chat.userName,
      userId: chat.userId,
    ))?.whenComplete(() {
      if(this.mounted){
        setState(() {
          controller.getChatList();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    socketConnection();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          controller.getChatList();
        });

    });
  }

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
  void dispose() {
    routeObserver.unsubscribe(this);
    chatListSocketService.onDisconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && !isFirstLoading) {
          isFirstLoading = true;
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.chatList.isEmpty) {
          return const Center(child: Text('채팅 내역이 없습니다.'));
        }

        return ListView.builder(
          itemCount: controller.chatList.length,
          itemBuilder: (context, index) {
            final chat = controller.chatList[index];
            final formattedDate = DateFormat('MM/dd HH:mm').format(chat.date.toLocal());

            return InkWell(
              onTap: () {
                goToChatScreen(chat);
              },
              child: Container(

                padding: const EdgeInsets.fromLTRB(7, 16, 16, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      width: 7,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.userName ?? '유저 이름 없음',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(chat.recentChat['role'] == 'doctor') ? '나' : chat.userName}: ${chat.recentChat['message']}',
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
                            int lastAutoIncrementID = snapshot.data!;
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
