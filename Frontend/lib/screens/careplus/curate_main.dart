import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/careplus/appointment_controller.dart';
import 'package:to_doc/screens/careplus/appointment_listview.dart';
import 'package:to_doc/screens/appointment/appointment_detail_screen.dart';

import '../../controllers/careplus/curate_list_controller.dart';
import 'package:get/get.dart';

import '../chat/dm_list.dart';
import 'curate_feed.dart';
import 'curate_list.dart';

class CurateMain extends StatefulWidget {
  const CurateMain({super.key});

  @override
  State<CurateMain> createState() => _CurateMainState();
}

class _CurateMainState extends State<CurateMain> {
  bool isLoading = true;
  final CurateListController curateListController = Get.put(CurateListController(dio:Dio()));
  final AppointmentController appointmentController = Get.put(AppointmentController());

  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date).toLocal();
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    return formattedDate;
  }

  asyncBefore() async {
    await curateListController.getList();
    await appointmentController.getAppointmentList();
    appointmentController.isLoading.value = false;
    setState(() {});
  }

  void initState() {
    asyncBefore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        //centerTitle: true,
        title: InkWell(
          child: Text('큐레이팅',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        //shape: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
        backgroundColor: Colors.grey.shade100,
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10,),
              if (appointmentController.approvedAppointment != -1 && appointmentController.isAfterTodayAppointmentExist.value) ... [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,),
                width: MediaQuery.of(context).size.width - 20,
                child: Obx (() {
                  if (appointmentController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Row(
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
                              if (appointmentController.isAfterTodayAppointmentExist
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
                                    .appointmentList[appointmentController.approvedAppointment]['doctor']['name']}, '
                                    '${DateFormat.yMMMEd('ko_KR').add_jm().format(appointmentController.appointmentList[appointmentController.approvedAppointment]['appointmentTime'])}'),
                              ],
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (appointmentController.isLoading.value) {
                            print('test2');
                            return;
                          }

                          print('test');
                          Get.to(()=>AppointmentListview(appointmentController: appointmentController));
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0, 50, 20, 0),
                          width: MediaQuery.of(context).size.width - 320,
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: Colors.grey))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('더보기', style: TextStyle(
                                  color: Colors.grey, fontSize: 10),),
                              Icon(Icons.arrow_forward_ios, color: Colors.grey.shade100,
                                size: 10,),
                            ],
                          ),
                        ),
                      ),
                    ]
                  );
                }),
              ),
              ],
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
                              //minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('전체보기', style: TextStyle(color: Colors.black),)),
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
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        height: 180,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            //final curateList = curateListController.CurateList[index];
                            //final commentCount = curateList['comments']?.length ?? 0;
                            return ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'ㅇㅇㅇ',
                                      style: TextStyle(
                                        //fontWeight: FontWeight.bold,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                  Text('1'),
                                ],
                              ),
                              subtitle: Text('TEST'),
                              onTap: (){
                                //curateListController.getPost(curateList['_id']);
                                //Get.to(()=> CurationScreen(currentId: curateList['_id']));
                              },
        
                            );
                          },
                          itemCount: curateListController.CurateList.length,
                        ),
                      ),
        
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border( top: BorderSide(color: Colors.grey.withAlpha(50)),)
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              Get.to(()=> DMList())?.whenComplete(() {
                                setState(() {
                                  asyncBefore();
                                });
                              });
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
        
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        title: const Text(
                          "큐레이팅 요청",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        content: const Text(
                          "주치의 큐레이팅 시스템을 활용하기 위해 본인의 AI 기반 고민 상담 기록을 제출하는 것에 동의합니다.",
                          overflow: TextOverflow.clip,
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); //팝업닫기
                            },
                            child: const Text(
                              "취소",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async{
                              Navigator.of(context).pop();
                              await curateListController.requestCurate();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: const Text("확인"),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[900],
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(50),
                  shadowColor: Colors.black,
                  elevation: 8,
                ),
                child: const Text(
                  "큐레이팅 받기",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
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
        hospital: appointmentController.hospital))?.whenComplete(() {asyncBefore();});
  }

}
