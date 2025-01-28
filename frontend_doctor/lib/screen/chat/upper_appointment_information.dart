import 'package:flutter/material.dart';

import '../../controllers/appointment_controller.dart';

class upperAppointmentInformation extends StatelessWidget {
  const upperAppointmentInformation({super.key, required this.appointmentController});

  final AppointmentController appointmentController;


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(50))),
      ),
      width: double.infinity,
      height: (appointmentController.isAppointmentExisted)? 80 : 0,
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
              Text('상대방이 아직 승낙하지 않았습니다.',
                style: TextStyle(fontSize: 10, color: Colors.grey),),
            ]
            else ... [
              Text('상대방이 약속을 승낙했습니다.',
                style: TextStyle(fontSize: 10, color: Colors.grey),),
            ],
          ]
        ],
      ),
    );
  }
}
