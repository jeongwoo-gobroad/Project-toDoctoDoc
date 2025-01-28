import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/careplus/chat_appointment_controller.dart';

class upperAppointmentInform extends StatelessWidget {
  const upperAppointmentInform({super.key, required this.appointmentController});

  final ChatAppointmentController appointmentController;

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
    return Column(
        children: [
          if (appointmentController.isAppointmentExisted) ...[
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
                      Text(DateFormat.yMMMEd('ko_KR').add_jm().format(appointmentController.appointment['appointmentTime']),
                        style: TextStyle(fontSize: 15, ),),
                    ],
                  ),
                  //Text('${appointmentController.appointmentId} : 약속 ID', style: TextStyle(fontSize: 10),),
                  if (!appointmentController.isAppointmentApproved) ...[
                    TextButton(
                      onPressed: () {
                        sendAppointmentApprovalAlert(context);
                      },
                      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                      child: Text('승낙'),
                    ),
                  ],
                ],
              ),
            ),
          ]
        ],
    );
  }
}
