import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/Database/chat_database.dart';
import 'package:to_doc/controllers/careplus/appointment_controller.dart';
import 'package:to_doc/screens/careplus/appointment_listview.dart';
import 'package:to_doc/screens/appointment/appointment_detail_screen.dart';
import 'package:to_doc/screens/careplus/nearby_curate_screen.dart';

import '../../controllers/careplus/chat_controller.dart';
import '../../controllers/careplus/curate_list_controller.dart';
import 'package:get/get.dart';

import '../chat/chat_screen.dart';
import '../chat/dm_list.dart';
import 'curate_feed.dart';
import 'curate_screen.dart';

class CurateMain extends StatefulWidget {
  const CurateMain({super.key});

  @override
  State<CurateMain> createState() => _CurateMainState();
}

class _CurateMainState extends State<CurateMain> {
  bool isLoading = true;
  final CurateListController curateListController = Get.put(CurateListController());
  final AppointmentController appointmentController = Get.put(AppointmentController());
  final ChatController chatController = Get.put(ChatController());
  final ChatDatabase chatDb = ChatDatabase();

  void goToChatScreen(chat) async {
    //print(chat.chatId);
    //linkTest();
    print('enter chat : ${chat.cid}');
    int lastAutoIncrementID;
    lastAutoIncrementID = await chatDb.getLastReadId(chat.cid);
    int unread = chat.recentChat['autoIncrementId'] - lastAutoIncrementID;
    await chatController.enterChat(chat.cid, lastAutoIncrementID);
    Get.to(()=> ChatScreen(doctorId: chat.doctorId, chatId: chat.cid, unreadMsg: unread, doctorName: chat.doctorName, autoIncrementId: chat.recentChat['autoIncrementId'],))?.whenComplete(() {
      setState(() {
        chatController.getChatList();
      });
    });
  }

  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date).toLocal();
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    
    appointmentController.getAppointmentList();
    chatController.getChatList();
    curateListController.getList();
  }
  Future<void> _handleCurateRequest() async {

  Get.dialog(
    Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  await curateListController.requestCurateNew(); 


  Get.back();

  if (curateListController.curateFinished.value) {
    Get.dialog(
      AlertDialog(
        title: const Text("완료"),
        content: const Text("맞춤병원 찾기 메뉴로 이동하시겠습니까?"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); 
              Get.to(() => NearbyCurateScreen());
            },
            child: const Text("확인"),
          ),
          TextButton(
            onPressed: () {
              Get.back(); 
            },
            child: const Text("취소"),
          ),
        ],
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        //centerTitle: true,
        title: InkWell(
          child: Text('큐레이팅',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: Colors.grey.shade100,
        // actions: [
        //   // Padding(
        //   //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //   //   child: ElevatedButton.icon(
        //   //     onPressed: () {
        //   //       Get.to(() => NearbyCurateScreen());
        //   //     },
        //   //     icon: Icon(Icons.local_hospital, color: Colors.redAccent),
        //   //     label: Text("내 맞춤 병원 찾기", style: TextStyle(color: Colors.black)),
        //   //     style: ElevatedButton.styleFrom(
        //   //       backgroundColor: Colors.white,
        //   //       shape: RoundedRectangleBorder(
        //   //         borderRadius: BorderRadius.circular(18.0),
        //   //       ),
        //   //     ),
        //   //   ),
        //   // ),
        // ],
        
      
      ),
      
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10,),

              Obx (() {
                if (appointmentController.isLoading.value) {
                  return Center(child: CircularProgressIndicator(),);
                }
                if (appointmentController.approvedAppointment != -1 &&
                    appointmentController.isAfterTodayAppointmentExist.value) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    width: MediaQuery.of(context).size.width - 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            onTaptoGo();
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (appointmentController
                                    .isAfterTodayAppointmentExist
                                    .value) ... [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_month),
                                      Text('가까운 약속이 있어요', style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text('${appointmentController
                                      .appointmentList[appointmentController
                                      .approvedAppointment]['doctor']['name']}, '
                                      '${DateFormat.yMMMEd('ko_KR')
                                      .add_jm()
                                      .format(appointmentController
                                      .appointmentList[appointmentController
                                      .approvedAppointment]['appointmentTime'])}'),
                                ],
                              ],
                            ),
                          ),
                        ),
                        



                        InkWell(
                          onTap: () {
                            if (appointmentController.isLoading.value) {
                              return;
                            }
                            Get.to(() => AppointmentListview(appointmentController: appointmentController));
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 50, 20, 0),
                            width: MediaQuery
                                .of(context)
                                .size
                                .width - 320,
                            decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(color: Colors.grey))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('더보기', style: TextStyle(
                                    color: Colors.grey, fontSize: 10),),
                                Icon(Icons.arrow_forward_ios,
                                  color: Colors.grey.shade100,
                                  size: 10,),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ),
                  );
                }
                else {
                  return SizedBox();
                }
              }),
              SizedBox(height: 10,),
        
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,),
                width: MediaQuery.of(context).size.width - 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: EdgeInsets.fromLTRB(20, 15, 0, 0),
                        child: Text('최근 큐레이팅 목록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)
                    ),
                    Obx (() {
                      if (curateListController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        height: 150,
                        child: ListView.builder(
                          itemCount: (curateListController.CurateList.length > 3)
                              ? 3 : curateListController.CurateList.length,
                          itemBuilder: (context, index) {
                            final curateList = curateListController.CurateList[index];
                            final commentCount = curateList['comments']?.length ?? 0;
                            return ListTile(
                              minVerticalPadding: 10,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width - 100,
                                    child: Text(
                                      '${formatDate(curateList['date'])}에 신청한 큐레이팅',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 15.0,),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.comment, size: 16),
                                      SizedBox(width: 3),
                                      Text('$commentCount'),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                curateListController.getPost(curateList['_id']);
                                Get.to(() => CurationScreen(currentId: curateList['_id']));
                              },
                            );
                          },
                        ),
                      );
                    }),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border( top: BorderSide(color: Colors.grey.withAlpha(50)),)
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Get.to(()=> CurateFeed());
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(0)),
                            ),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('전체보기', style: TextStyle(color: Colors.black),)
                        ),
                      ),
                    )
                  ],
                ),
              ),
        
              SizedBox(height: 10,),
        
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.fromLTRB(20, 15, 0, 0),
                          child: Text('최근 DM 목록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)
                      ),
                      Obx(() {
                        if (chatController.isLoading.value) {
                          return Center(child: CircularProgressIndicator(),);
                        }

                        return Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          height: 180,
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              final chat = chatController.chatList[index];
                              print(chat.cid);
                              //final formattedDate = DateFormat('MM/dd HH:mm').format(chat.date.toLocal());
                              // final commentCount = curateList['comments']?.length ?? 0;

                              return ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chat.doctorName,
                                        style: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ),
                                    //Text(chat.unreadChat.toString()),
                                  ],
                                ),
                                subtitle: Text(
                                  '${(chat.recentChat['role'] == 'doctor') ? chat.doctorName : '나'}: ${chat.recentChat['message']}',),
                                onTap: () {
                                  goToChatScreen(chat);
                                },
                              );
                            },
                            itemCount: (chatController.chatList.length > 3) ? 3 : chatController.chatList.length,
                          ),
                        );
                      }),
        
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border( top: BorderSide(color: Colors.grey.withAlpha(50)),)
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              if (chatController.isLoading.value) {
                                return;
                              }

                              // Get.to(()=> DMList(controller: chatController,))?.whenComplete(() {
                              //   setState(() {
                              //     chatController.getChatList();
                              //   });
                              // });
                              Get.to(()=> DMList(controller: chatController));
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(0)),
                              ),
                              //minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('전체보기', style: TextStyle(color: Colors.black),)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: const Text(
          "큐레이팅 요청",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        content: const Text(
          "주치의 큐레이팅 시스템을 활용하기 위해 본인의 AI 기반 고민 상담 기록을 제출하는 것에 동의합니다.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Get.back(); 
              await _handleCurateRequest(); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 225, 234, 205),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text("확인"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  },
  icon: const Icon(Icons.auto_awesome),
  label: const Text("큐레이팅 받기", style: TextStyle(color: Colors.black)),
  backgroundColor: const Color.fromARGB(255, 225, 234, 205),
),
    );
  }

  onTaptoGo() async {
    if (appointmentController.isLoading.value) {
      return;
    }
    await appointmentController.getAppointmentInformation(appointmentController.appointmentList[appointmentController.nearAppointment]['_id']);

    Get.to(() => AppointmentDetailScreen(
        doctorName: appointmentController.appointmentList[appointmentController.nearAppointment]['doctor']['name'],
        appointment: appointmentController.appointment,
        hospital: appointmentController.hospital))?.whenComplete(() {
          appointmentController.getAppointmentList();
    });
  }

}
