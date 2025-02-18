import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/appointment_controller.dart';
import 'appointment_detail_screen.dart';

class AppointmentListview extends StatefulWidget {
  const AppointmentListview({super.key});

  @override
  State<AppointmentListview> createState() => _AppointmentListviewState();
}

class _AppointmentListviewState extends State<AppointmentListview> with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  late TabController tabController = TabController(length: 2, vsync: this, initialIndex: 1, animationDuration: const Duration(milliseconds: 300));
  AppointmentController appointmentController = Get.find<AppointmentController>();

  bool checkIfDayChanged(index) {
    if (index == 0) {
      return true;
    }
    if ((appointmentController.appList[index-1].startTime.day != appointmentController.appList[index].startTime.day)) {
      return true;
    }
    return false;
  }

  gotoDetailScreen(index) async {
    showDialog(
      context: context,
      builder: (context) {
        return AppointmentDetailScreen(appointment: appointmentController.appList[index]);
      },
    );
  }

  @override
  void initState() {
    appointmentController.getAppointmentList();
    super.initState();
  }

  Future<void> isReallyAppointmentDoneAlert(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주의'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '정말 약속이 완료되었나요?',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: ()  {
                Navigator.of(context).pop();
              },
              child: Text('취소', style: TextStyle(color:Colors.grey),),
            ),
            TextButton(
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
              child: Text('확정'),
              onPressed: () async {

                if (await appointmentController.sendAppointmentIsDone(appointmentController.appList[index].id)) {
                  // todo 완료 메세지 추가 필요
                  appointmentController.appList[index].isDone = true;
                  Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: InkWell(
            child: Text('예약 리스트(가)',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ),
          bottom: TabBar(controller: tabController, tabs: [Tab(text: '지나간 약속',), Tab(text: '남은 약속',)])
      ),
      body: TabBarView(
        controller: tabController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Obx(() {
            if (appointmentController.isLoading.value) {
              return Center(child: CircularProgressIndicator(),);
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    //shrinkWrap: true,
                    controller: scrollController,
                    itemCount: appointmentController.nearAppointment,
                    itemBuilder: (context, index) {
                      final nowApp = appointmentController.appList[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (checkIfDayChanged(index)) ... [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300),
                                  top: BorderSide(color: Colors.grey.shade300),
                                )
                              ),
                              child: Text(DateFormat.yMMMEd('ko_KR').format(nowApp.startTime)),
                            ),
                          ],
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            //decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300),)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(DateFormat.jm('ko_KR').format(nowApp.startTime), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                    SizedBox(width: 10),
                                    Text('${nowApp.userNick}와의 약속' , style: TextStyle(fontSize: 20),),
                                  ],
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        gotoDetailScreen(index);
                                      },
                                      child: Wrap (
                                        children: [
                                          if (nowApp.isFeedBackDone) ... [
                                            if (nowApp.feedback['rating'] == 0) ... [
                                              SvgPicture.asset('asset/images/emoji/frowning-face.svg', width: 30),
                                            ]
                                            else if (nowApp.feedback['rating'] == 1) ... [
                                              SvgPicture.asset('asset/images/emoji/neutral-face.svg', width: 30),
                                            ]
                                            else ... [
                                              SvgPicture.asset('asset/images/emoji/grinning-squinting-face.svg', width: 30),
                                            ],
                                          ],
                                        ]
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    InkWell(
                                      onTap: () {
                                        if (nowApp.isDone) return;
                                        isReallyAppointmentDoneAlert(context, index);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: (nowApp.isDone)? Colors.green : Colors.grey,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Text((nowApp.isDone)? '완료' : '미완료', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ],
            );
          }),

          Obx(() {
            if (appointmentController.isLoading.value) {
              return Center(child: CircularProgressIndicator(),);
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    //shrinkWrap: true,
                    controller: scrollController,
                    itemCount: appointmentController.appList.length - appointmentController.nearAppointment,
                    itemBuilder: (context, index) {
                      /*if (!widget.appointmentController.appointmentList[index]['isAppointmentApproved']) {
                        return SizedBox(height: 20, child: Text('미승인 약속입니다.'),);
                      }*/
                      final nowApp = appointmentController.appList[index + appointmentController.nearAppointment];

                      return Column(
                        children: [
                          if (checkIfDayChanged(index + appointmentController.nearAppointment)) ... [
                            Text(DateFormat.yMMMEd('ko_KR').format(nowApp.startTime)),
                          ],
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black), top: BorderSide(color: Colors.black),)),
                            child: Column(
                              children: [
                                Text('예약 ID ${nowApp.id}'),
                                Text('유저 ID ${nowApp.userNick}'),
                                Text('승인 : ${nowApp.isApproved}'),
                                Text(DateFormat.yMMMEd('ko_KR').add_jm().format(nowApp.startTime)),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ],
            );
          }),
        ],
      )
    );
  }


}
