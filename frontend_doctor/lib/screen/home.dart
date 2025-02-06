import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';
import 'package:to_doc_for_doc/controllers/curate/curate_controller.dart';
import 'package:to_doc_for_doc/screen/appointment/appointment_listview.dart';
import 'appointment/appointment_detail_screen.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CurateController curateController = Get.put(CurateController(dio: Dio()));
  AppointmentController appointmentController = AppointmentController();
  ScrollController scrollController = ScrollController();

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toUtc().add(Duration(hours: 9));

      return DateFormat.yMd('ko_KR').add_Hm().format(dateTime);

      return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }

  gotoDetainScreen(index) async {
    Get.to(()=>AppointmentDetailScreen(appointmentController: appointmentController, appointment: appointmentController.appointmentList[index]));
  }

  makeAppointmentList() {
    if (appointmentController.isLoading.value) {
      return Center(child: CircularProgressIndicator(),);
    }
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: appointmentController.appointmentList.length - appointmentController.nearAppointment,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(color: Colors.grey.shade100))),
            height: 55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${appointmentController.appointmentList[index + appointmentController.nearAppointment]['user']['usernick']}와의 약속', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                Text(DateFormat.yMMMEd('ko_KR').add_jm().format(appointmentController.appointmentList[index + appointmentController.nearAppointment]['appointmentTime']),
                  style: TextStyle(color: (appointmentController.appointmentList[index + appointmentController.nearAppointment]['appointmentTime'].day == DateTime.now().day)? Colors.red : null),),
              ],
            ),
          );
        },
      )
    );
  }

  asyncBefore() async {
    //await curateController.getCurateInfo('5');
    await appointmentController.getSimpleInformation();
    setState(() {});
  }

  @override
  void initState() {
    asyncBefore();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        centerTitle: true,
        title: Text('토닥toDoc - Doctor',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  //border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 70,
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        decoration: BoxDecoration(
                          border: BorderDirectional(bottom: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: //Center(
                          /*child: */Text('다가오는 예약', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          //),
                        ),
                      ),
                      SizedBox(width: 30),

                      makeAppointmentList(),

                      Container(
                        width : double.infinity,
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        decoration: BoxDecoration(
                          border: BorderDirectional(top: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () {
                            if (appointmentController.isLoading.value) {
                              return;
                            }
                            Get.to(()=>AppointmentListview(appointmentController: appointmentController));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('더보기', style: TextStyle(fontSize: 15, color: Colors.grey),),
                              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 15,),
                            ],
                          ),
                        ),
                      ),
                    ],
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
