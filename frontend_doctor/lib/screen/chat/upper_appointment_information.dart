import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/chat_appointment_controller.dart';

class UpperAppointmentInformation extends StatefulWidget {
  const UpperAppointmentInformation({super.key, required this.appointmentController, required this.chatId});

  final ChatAppointmentController appointmentController;
  final String chatId;

  @override
  State<UpperAppointmentInformation> createState() => _UpperAppointmentInformationState();
}

class _UpperAppointmentInformationState extends State<UpperAppointmentInformation> {
  late Timer _timer;


  void getAppointment(Timer timer) {
    widget.appointmentController.getAppointmentInformation(widget.chatId);
    if(mounted){
    setState(() {    });
    }
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
    if (widget.appointmentController.isAppointmentExisted.value && !widget.appointmentController.isAppointmentDone.value) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.calendar_month),
                    Text('이 환자와 약속이 있어요',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),),
                  ],),
                  Text(DateFormat.yMMMEd('ko_KR').add_jm().format(
                      widget.appointmentController.appointmentTime.value),
                    style: TextStyle(fontSize: 15,),),
                ],
              ),
              SizedBox(height:5),
              //Text('${appointmentController.appointmentId} : 약속 ID', style: TextStyle(fontSize: 10),),

              if (widget.appointmentController.appointmentTime.value.isAfter(DateTime.now())) ... [
                if (!widget.appointmentController.isAppointmentApproved.value) ...[
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
