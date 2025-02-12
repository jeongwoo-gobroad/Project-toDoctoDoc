import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key, required this.appointment});

  final Map<String, dynamic> appointment;

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  AppointmentController appointmentController = Get.find<AppointmentController>();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.8,
        builder: (BuildContext context, ScrollController scrollController) {
        return DefaultTextStyle(
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
          child: Wrap(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white),
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20,),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10,),
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
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );

  }
}
