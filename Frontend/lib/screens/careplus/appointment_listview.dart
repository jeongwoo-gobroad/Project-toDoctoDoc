import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/careplus/appointment_controller.dart';
import 'package:to_doc/screens/chat/appointment_detail_screen.dart';

class AppointmentListview extends StatefulWidget {
  const AppointmentListview({super.key, required this.appointmentController});
  
  final AppointmentController appointmentController;

  @override
  State<AppointmentListview> createState() => _AppointmentListviewState();
}

class _AppointmentListviewState extends State<AppointmentListview> with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  late TabController tabController = TabController(length: 2, vsync: this, initialIndex: 1, animationDuration: const Duration(milliseconds: 300));

  bool checkIfDayChanged(index) {
    if (index == 0) {
      return true;
    }
    if ((widget.appointmentController.appointmentList[index-1]['appointmentTime'].day != widget.appointmentController.appointmentList[index]['appointmentTime'].day)) {
      return true;
    }
    return false;
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
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.appointmentController.nearAppointment,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      if (checkIfDayChanged(index)) ... [
                        Text(DateFormat.yMMMEd('ko_KR').format(widget.appointmentController.appointmentList[index]['appointmentTime'])),
                      ],

                      InkWell(
                        onTap: () {
                          gotoDetainScreen(index);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black), top: BorderSide(color: Colors.black),)),
                          child: Column(
                            children: [
                              Text('예약 ID ${widget.appointmentController.appointmentList[index]['_id']}'),
                              Text('의사 ID ${widget.appointmentController.appointmentList[index]['doctor']['_id']}'),
                              Text(DateFormat.yMMMEd('ko_KR').add_jm().format(widget.appointmentController.appointmentList[index]['appointmentTime'])),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),


            Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.appointmentController.appointmentList.length - widget.appointmentController.nearAppointment,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        if (checkIfDayChanged(index)) ... [
                          Text(DateFormat.yMMMEd('ko_KR').format(widget.appointmentController.appointmentList[index]['appointmentTime'])),
                        ],

                        InkWell(
                          onTap: () {
                            gotoDetainScreen(index);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black), top: BorderSide(color: Colors.black),)),
                            child: Column(
                              children: [
                                Text('예약 ID ${widget.appointmentController.appointmentList[index + widget.appointmentController.nearAppointment]['_id']}'),
                                Text('의사 ID ${widget.appointmentController.appointmentList[index + widget.appointmentController.nearAppointment]['doctor']['_id']}'),
                                Text(DateFormat.yMMMEd('ko_KR').add_jm().format(widget.appointmentController.appointmentList[index + widget.appointmentController.nearAppointment]['appointmentTime'])),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );

                  }),
            ),
          ],
        )
    );
  }

  gotoDetainScreen(index) async {
    await widget.appointmentController.getAppointmentInformation(widget.appointmentController.appointmentList[index]['_id']);
    Get.to(()=>AppointmentDetailScreen(appointment: widget.appointmentController.appointment, hospital: widget.appointmentController.hospital, doctorName: '못받아옴'));
  }
}
