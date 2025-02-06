import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/controllers/chat_appointment_controller.dart';

class AppointmentBottomSheet extends StatefulWidget {
  final String userName;

  final ChatAppointmentController chatAppointmentController;

  AppointmentBottomSheet({
    required this.userName,
    required this.chatAppointmentController, this.alterParent,
  });

  final alterParent;

  @override
  State<AppointmentBottomSheet> createState() => _appointmentBottomSheet();
}

class _appointmentBottomSheet extends State<AppointmentBottomSheet> with WidgetsBindingObserver {
  DateTime selectedDay = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    if (!widget.chatAppointmentController.isAppointmentExisted.value || widget.chatAppointmentController.isAppointmentDone.value) {
      widget.chatAppointmentController.initialDay = DateTime.now();
      widget.chatAppointmentController.initialTime = TimeOfDay.now();
    }

    selectedDay = widget.chatAppointmentController.initialDay;
    selectedTime = widget.chatAppointmentController.initialTime;
  }

  DateTime addDayTime(DateTime day, TimeOfDay time) {
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Future<void> setAppointmentAlert(BuildContext context) async {
    return showDialog<void>(
      //다이얼로그 위젯 소환
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주의'),
          content: SingleChildScrollView(
            child: ListBody(
              //List Body를 기준으로 Text 설정
              children: <Widget>[
                if ((!widget.chatAppointmentController.isAppointmentExisted.value) || widget.chatAppointmentController.isAppointmentDone.value) ...[
                  Text(
                    '${widget.userName}와 ${addDayTime(selectedDay, selectedTime).toString()}에 정말 예약신청하겠습니까?',
                    style: TextStyle(fontWeight: FontWeight.bold),),
                ]
                else ...[
                  Text(
                    '${widget.userName}와 ${addDayTime(selectedDay, selectedTime).toString()}으로 정말 예약수정하겠습니까?',
                    style: TextStyle(fontWeight: FontWeight.bold),),
                ],

              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final finalTime = addDayTime(selectedDay, selectedTime);

                int nowInMinutes = selectedTime.hour * 60 + selectedTime.minute;
                int testDateInMinutes = selectedEndTime.hour * 60 + selectedEndTime.minute;

                if ((!widget.chatAppointmentController.isAppointmentExisted.value) || widget.chatAppointmentController.isAppointmentDone.value) {
                  widget.chatAppointmentController.makeAppointment(finalTime, testDateInMinutes - nowInMinutes);
                }
                else {
                  widget.chatAppointmentController.editAppointment(finalTime, testDateInMinutes - nowInMinutes);
                }

                widget.alterParent();


                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
              child: Text('예약', style: TextStyle(color:Colors.white),),
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

  Future<void> deleteAppointmentAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('주의'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${widget.userName}와 ${addDayTime(selectedDay, selectedTime).toString()}의 약속을 정말 삭제하시겠습니까?',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                widget.chatAppointmentController.deleteAppointment();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
              child: Text('삭제', style: TextStyle(color:Colors.white),),
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
    return DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.4,
        maxChildSize: 1.0,
        builder: (BuildContext context,
            ScrollController scrollController) {
          return
            Wrap(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    left: 40,
                    right: 40,
                    bottom: 100,
                  ),
                  height: 400,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),

/*          child: Wrap(
                      children: [*/
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        width: 200,
                        height: 5,
                        decoration: BoxDecoration(
                            color: Colors.grey
                        ),
                      ),

                      if ((!widget.chatAppointmentController.isAppointmentExisted.value) || widget.chatAppointmentController.isAppointmentDone.value) ...[
                        Text('약속 잡기',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ]
                      else ...[
                        Text('약속 수정',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],


                      TextButton(
                          onPressed: () async {
                            final selectedDateSub = await showDatePicker(
                              context: context,
                              firstDate: widget.chatAppointmentController.initialDay,
                              lastDate: DateTime(2030),
                            );
                            if (selectedDateSub != null) {
                              setState(() {
                                selectedDay = selectedDateSub;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Text('날짜 선택', style: TextStyle(fontSize: 15),),
                              SizedBox(width: 10,),
                              Icon(CupertinoIcons.right_chevron),
                              SizedBox(width: 20,),
                              Text(DateFormat("yyyy년 MM월 dd일").format(selectedDay), style: TextStyle(fontSize: 15),),
                            ],
                          ),
                      ),

                      TextButton(
                        onPressed: () async {
                          final selectedTimeSub = await showTimePicker(
                            context: context,
                            initialTime: widget.chatAppointmentController.initialTime,
                          );
                          if (selectedTimeSub != null) {
                            setState(() {
                              selectedTime = selectedTimeSub;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Text('시작 시각 선택', style: TextStyle(fontSize: 15),),
                            SizedBox(width: 10,),
                            Icon(CupertinoIcons.right_chevron),
                            SizedBox(width: 20,),
                            Text('${selectedTime.hour.toString()} : ${selectedTime.minute.toString()}', style: TextStyle(fontSize: 15),),
                          ],
                        ),
                      ),

                      TextButton(
                        onPressed: () async {
                          final selectedTimeSub = await showTimePicker(
                            context: context,
                            initialTime: widget.chatAppointmentController.initialTime,
                          );
                          if (selectedTimeSub != null) {
                            if (this.mounted) {
                              setState(() {
                                selectedEndTime = selectedTimeSub;
                              });
                            }
                          }
                        },
                        child: Row(
                          children: [
                            Text('완료 시각 선택', style: TextStyle(fontSize: 15),),
                            SizedBox(width: 10,),
                            Icon(CupertinoIcons.right_chevron),
                            SizedBox(width: 20,),
                            Text('${selectedEndTime.hour.toString()} : ${selectedEndTime.minute.toString()}', style: TextStyle(fontSize: 15),),
                          ],
                        ),
                      ),

                      SizedBox(height:50),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.chatAppointmentController.isAppointmentExisted.value && !widget.chatAppointmentController.isAppointmentDone.value) ... [
                            TextButton(
                                style: TextButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () {
                                  deleteAppointmentAlert(context);
                                },
                                child: Text('약속 삭제', style: TextStyle(fontSize: 20, color: Colors.white),)
                            ),

                          ],
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('취소', style: TextStyle(fontSize: 20, color: Colors.grey),)
                          ),

                          SizedBox(width: 20,),

                          TextButton(
                              onPressed: () {
                                print('미완성');
                                setAppointmentAlert(context);
                                //Navigator.of(context).pop();
                              },
                              child: Text('결정', style: TextStyle(fontSize: 20, color: Colors.blue),)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
        }
    );
  }

}