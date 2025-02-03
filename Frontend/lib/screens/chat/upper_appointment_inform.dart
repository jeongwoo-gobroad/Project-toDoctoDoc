import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/careplus/chat_appointment_controller.dart';

class UpperAppointmentInform extends StatefulWidget {
  const UpperAppointmentInform({super.key, required this.appointmentController, required this.chatId});

  final ChatAppointmentController appointmentController;
  final String chatId;

  @override
  State<UpperAppointmentInform> createState() => _UpperAppointmentInformState();
}

class _UpperAppointmentInformState extends State<UpperAppointmentInform> {
  late Timer _timer;

  void getAppointment(Timer timer) {
    widget.appointmentController.getAppointmentInformation(widget.chatId);
    setState(() {    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds:1),
      getAppointment,
    );
  }


  Future<void> sendAppointmentApprovalAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주의'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '약속을 확정하시겠습니까?',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('취소', style: TextStyle(color: Colors.grey),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () {
                widget.appointmentController.sendAppointmentApproval();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green)),
              child: Text('승낙', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        _timer.cancel();
      },
      child: Column(
          children: [
            if (widget.appointmentController.isAppointmentExisted) ...[
              Container(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
                  //color: Color.fromARGB(255, 244, 242, 248),
                  ),
                width: double.infinity,
              //height: (appointmentController.isAppointmentExisted)? 100 : 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month),
                            Text('이 의사와 약속이 있어요', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                          ],
                        ),
                        Text(DateFormat.yMMMEd('ko_KR').add_jm().format(widget.appointmentController.appointment['appointmentTime']),
                          style: TextStyle(fontSize: 15, ),),
                      ],
                    ),
                    //Text('${appointmentController.appointmentId} : 약속 ID', style: TextStyle(fontSize: 10),),
                    if (!widget.appointmentController.isAppointmentApproved) ...[
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            sendAppointmentApprovalAlert(context);
                          },
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green),),
                          child: Text('승낙', style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ]
          ],
      ),
    );
  }
}
