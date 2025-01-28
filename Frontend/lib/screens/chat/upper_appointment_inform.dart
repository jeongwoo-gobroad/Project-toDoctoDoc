import 'package:flutter/material.dart';

import '../../controllers/careplus/appointment_controller.dart';

class upperAppointmentInform extends StatelessWidget {
  const upperAppointmentInform({super.key, required this.appointmentController});

  final AppointmentController appointmentController;

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
              onPressed: () {
                appointmentController.sendAppointmentApproval();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green)),
              child: Text('승낙', style: TextStyle(color: Colors.black),),
            ),
            TextButton(
              child: Text('취소', style: TextStyle(color: Colors.grey),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
      ),
      width: double.infinity,
      //height: (appointmentController.isAppointmentExisted)? 100 : 0,
      child: Column(
        children: [
          if (appointmentController.isAppointmentExisted) ...[
            Text('약속이 존재합니다',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
            Text('${appointmentController.appointmentId} : 약속 ID',
              style: TextStyle(fontSize: 10),),
            Text('${appointmentController.appointmentTime}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

            if (!appointmentController.isAppointmentApproved) ...[
              TextButton(
                onPressed: () {
                  sendAppointmentApprovalAlert(context);
                },
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                child: Text('승낙'),
              ),
            ],
          ]
        ],
      ),
    );
  }
}
