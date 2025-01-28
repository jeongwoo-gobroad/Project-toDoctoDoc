import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';

import '../../controllers/appointment_controller.dart';

class UpperAppointmentInformation extends StatelessWidget {
  const UpperAppointmentInformation(
      {super.key, required this.appointmentController});

  final AppointmentController appointmentController;

  @override
  Widget build(BuildContext context) {
    if (appointmentController.isAppointmentExisted) {
      return Container(
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
                    appointmentController.appointmentTime),
                  style: TextStyle(fontSize: 15,),),
              ],
            ),
            Text('${appointmentController.appointmentId} : 약속 ID',
              style: TextStyle(fontSize: 10),),

            if (!appointmentController.isAppointmentApproved) ...[
              Text('상대방이 아직 승낙하지 않았습니다.',
                style: TextStyle(fontSize: 10, color: Colors.grey),),
            ]
            else
              ... [
                Text('상대방이 약속을 승낙했습니다.',
                  style: TextStyle(fontSize: 10, color: Colors.grey),),
              ],
          ]
        ),
      );
    }
    else {
      return Text('이 환자와 약속이 없습니다');
    }
  }
}
