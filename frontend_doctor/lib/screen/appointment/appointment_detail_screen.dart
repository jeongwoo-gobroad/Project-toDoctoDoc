import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentController, required this.appointment});

  final AppointmentController appointmentController;
  final Map<String, dynamic> appointment;

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {

  Future<void> isReallyAppointmentDoneAlert(BuildContext context) async {
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

                if (await widget.appointmentController.sendAppointmentIsDone(widget.appointment['_id'])) {
                  // todo 완료 메세지 추가 필요
                  widget.appointment['hasAppointmentDone'] = true;
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
          child: Text('과거 예약 정보(가)',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: Column(
                children: [
                  Text('정보', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                  SizedBox(height: 5),

                  Text(widget.appointment['_id'] ?? ''),
                  Text(widget.appointment['user']['usernick'] ?? ''),
                  Text(DateFormat.yMMMEd('ko_KR').add_jm().format(widget.appointment['appointmentTime'])),
                  Text(widget.appointment['isAppointmentApproved'].toString()),
                  Text(widget.appointment['hasAppointmentDone'].toString()),
                  Text(widget.appointment['hasFeedbackDone'].toString()),
                  Text(widget.appointment['appointmentCreatedAt'] ?? ''),
                  Text(widget.appointment['appointmentEditedAt'] ?? ''),
                ],
              ),
            ),
            SizedBox(height: 5),

            if (!widget.appointment['hasAppointmentDone']) ... [
              TextButton(onPressed: () {
                setState(() {
                  isReallyAppointmentDoneAlert(context);
                });
              }, child: Text('약속 완료'),)
            ],

            if (widget.appointment['hasFeedbackDone']) ... [
              Container(
                child: Column(
                  children: [
                    Text('피드백 정보', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                    SizedBox(height: 5),
                    
                    Text('얼마나 좋았나요?'),
                    if (widget.appointment['feedback']['rating'] == 0) Text('별로였어요'),
                    if (widget.appointment['feedback']['rating'] == 1) Text('보통이였어요'),
                    if (widget.appointment['feedback']['rating'] == 2) Text('좋았어요'),
                    Text(widget.appointment['feedback']['content'] ?? ''),
                  ],
                ),
              ),
            ] else ... [Center(child: Text('아직 피드백이 없습니다')),],
          ],
        ),
      ),
    );
  }
}
