import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20,),
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 5),
                    Text('피드백 정보', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    SizedBox(height: 25),

                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              //Text('얼마나 좋았나요?'),
                              if (widget.appointment['feedback']['rating'] == 0) ... [
                                SvgPicture.asset('asset/images/emoji/frowning-face.svg', width: 50),
                                SizedBox(height: 10,),
                                Text('별로였어요'),
                              ]
                              else if (widget.appointment['feedback']['rating'] == 1) ... [
                                SvgPicture.asset('asset/images/emoji/neutral-face.svg', width: 50),
                                SizedBox(height: 10,),
                                Text('보통이였어요'),
                              ]
                              else ... [
                                SvgPicture.asset('asset/images/emoji/grinning-squinting-face.svg', width: 50),
                                SizedBox(height: 10,),
                                Text('좋았어요'),
                              ],
                              //Text('피드백 내용', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Text(widget.appointment['feedback']['content'] ?? '', 
                            style: TextStyle(fontSize: 15),),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
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
