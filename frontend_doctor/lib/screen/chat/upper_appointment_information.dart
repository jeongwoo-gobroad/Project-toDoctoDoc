import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../controllers/chat_appointment_controller.dart';

class UpperAppointmentInformation extends StatefulWidget {
  const UpperAppointmentInformation({super.key,required this.chatId});
  final String chatId;


  @override
  State<UpperAppointmentInformation> createState() => _UpperAppointmentInformationState();
}

class _UpperAppointmentInformationState extends State<UpperAppointmentInformation> {
  ChatAppointmentController appointmentController = Get.find<ChatAppointmentController>();
  late Timer _timer;

  void getAppointment(Timer timer) {
    print('reload appointment');
    if (!mounted) {
      _timer.cancel();
    }
    appointmentController.getAppointmentInformation(widget.chatId);
    setState(() {    });
  }

  void cancelTimer() {
    _timer.cancel();
  }

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds:1),
      getAppointment,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (appointmentController.isAppointmentExisted.value && !appointmentController.isAppointmentDone.value) {
      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          _timer.cancel();
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
          ),
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Icon(Icons.calendar_month),
                    Text('이 환자와 약속이 있어요',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),),
                  ],),

                ],
              ),
              SizedBox(height:5),
              //Text('${appointmentController.appointmentId} : 약속 ID', style: TextStyle(fontSize: 10),),
              Text('${DateFormat.yMMMEd('ko_KR').add_Hm().format(appointmentController.appointmentTime.value)} ~ ${DateFormat.Hm('ko_KR').format(appointmentController.appointmentEndTime.value)}',
                style: TextStyle(fontSize: 15,),),

              if (appointmentController.appointmentTime.value.isAfter(DateTime.now())) ... [
                if (!appointmentController.isAppointmentApproved.value) ...[
                  Text('상대방이 아직 승낙하지 않았습니다.',
                    style: TextStyle(color: Colors.grey),),
                ]
                else ... [
                    Text('상대방이 약속을 승낙했습니다.',
                      style: TextStyle(color: Colors.grey),),
                ],
              ]
              else ... [
                Text('약속이 완료되지 않았습니다.', style: TextStyle(color: Colors.grey),),
              ],
            ]
          ),
        ),
      );
    }
    else {
      return Text('이 환자와 약속이 없습니다');
    }
  }
}
