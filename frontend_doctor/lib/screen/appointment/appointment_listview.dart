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
    if ((appointmentController.appList[index-1]['appointmentTime'].day != appointmentController.appList[index]['appointmentTime'].day)) {
      return true;
    }
    return false;
  }

  asyncBefore() async {
    await appointmentController.getAppointmentList();
  }


  @override
  void initState() {
    asyncBefore();
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

                if (await appointmentController.sendAppointmentIsDone(appointmentController.appList[index]['_id'])) {
                  // todo 완료 메세지 추가 필요
                  appointmentController.appList[index]['hasAppointmentDone'] = true;
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
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: scrollController,
                      itemCount: appointmentController.nearAppointment,
                      itemBuilder: (context, index) {

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
                                  child: Text(DateFormat.yMMMEd('ko_KR').format(appointmentController.appList[index]['appointmentTime'])),
                                ),
                              ],

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                //decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300),)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(DateFormat.jm('ko_KR').format(appointmentController.appList[index]['appointmentTime']), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                        SizedBox(width: 10),
                                        Text('${appointmentController.appList[index]['user']['usernick']}와의 약속' , style: TextStyle(fontSize: 20),),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            gotoDetainScreen(index);
                                          },
                                          child: Wrap (
                                            children: [
                                              if (appointmentController.appList[index]['hasFeedbackDone']) ... [
                                                if (appointmentController.appList[index]['feedback']['rating'] == 0) ... [
                                                  SvgPicture.asset('asset/images/emoji/frowning-face.svg', width: 30),
                                                ]
                                                else if (appointmentController.appList[index]['feedback']['rating'] == 1) ... [
                                                  SvgPicture.asset('asset/images/emoji/neutral-face.svg', width: 30),
                                                ]
                                                else ... [
                                                  SvgPicture.asset('asset/images/emoji/grinning-squinting-face.svg', width: 30),
                                                ],
                                              ],
                                            ]
                                          ),
                                        ),

                                        InkWell(
                                          onTap: () {
                                            if (appointmentController.appList[index]['hasAppointmentDone']) return;
                                            isReallyAppointmentDoneAlert(context, index);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                                color: (appointmentController.appList[index]['hasAppointmentDone'])? Colors.green : Colors.grey,
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: Text((appointmentController.appList[index]['hasAppointmentDone'])? '완료' : '미완료', style: TextStyle(color: Colors.white)),
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
            ),


            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: scrollController,
                      itemCount: appointmentController.appList.length - appointmentController.nearAppointment,
                      itemBuilder: (context, index) {
                        /*if (!widget.appointmentController.appointmentList[index]['isAppointmentApproved']) {
                          return SizedBox(height: 20, child: Text('미승인 약속입니다.'),);
                        }*/
                        return Column(
                          children: [
                            if (checkIfDayChanged(index + appointmentController.nearAppointment)) ... [
                              Text(DateFormat.yMMMEd('ko_KR').format(appointmentController.appList[index + appointmentController.nearAppointment]['appointmentTime'])),
                            ],
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black), top: BorderSide(color: Colors.black),)),
                              child: Column(
                                children: [
                                  Text('예약 ID ${appointmentController.appList[index + appointmentController.nearAppointment]['_id']}'),
                                  Text('유저 ID ${appointmentController.appList[index + appointmentController.nearAppointment]['user']['usernick']}'),
                                  Text('승인 : ${appointmentController.appList[index]['isAppointmentApproved']}'),
                                  Text(DateFormat.yMMMEd('ko_KR').add_jm().format(appointmentController.appList[index + appointmentController.nearAppointment]['appointmentTime'])),
                                ],
                              ),
                            ),
                          ],
                        );

                      }),
                ),
              ],
            ),
          ],
        )
    );
  }

  gotoDetainScreen(index) async {
    //await widget.appointmentController.getAppointmentInformation(widget.appointmentController.appointmentList[index]['_id']);

    showDialog(

      context: context,
      builder: (context) {
        return AppointmentDetailScreen(appointment: appointmentController.appList[index]);
      },
    );
    //Get.to(()=>AppointmentDetailScreen(appointment: appointmentController.appointmentList[index]));
  }
}
