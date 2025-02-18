import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';
import 'package:to_doc_for_doc/controllers/chat_appointment_controller.dart';

class AppointmentBottomSheet extends StatefulWidget {
  final String userName;
  final alterParent;

  AppointmentBottomSheet({
    required this.userName,
    this.alterParent,
  });

  @override
  State<AppointmentBottomSheet> createState() => _AppointmentBottomSheet();
}

class _AppointmentBottomSheet extends State<AppointmentBottomSheet> with WidgetsBindingObserver {
  ChatAppointmentController chatAppController = Get.find<ChatAppointmentController>();
  AppointmentController appController = Get.find<AppointmentController>();
  List<int> nowAppList = [];

  Widget dowBuilder(context, day) {
    if (day.weekday == DateTime.saturday) {
      return Center(
        child: Text(DateFormat.E('ko').format(day),
          style: TextStyle(color: Colors.blue),),
      );
    }
    else if (day.weekday == DateTime.sunday) {
      return Center(
        child: Text(DateFormat.E('ko').format(day),
          style: TextStyle(color: Colors.red),),
      );
    }
    else {
      return Center(
        child: Text(DateFormat.E('ko').format(day),
          style: TextStyle(color: Colors.black),),
      );
    }
  }
  Widget defaultBuilder(context, day, focusedDay) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.topCenter,
        child: Text('${day.day}')
    );
  }
  Widget outsideBuilder(context, day, focusedDay) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.topCenter,
        child: Text('${day.day}', style: TextStyle(color: Colors.grey),)
    );
  }
  Widget disabledBuilder(context, day, focusedDay) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.topCenter,
        child: Text('${day.day}', style: TextStyle(color: Colors.grey),)
    );
  }
  Widget todayBuilder(context, day, selectedDay) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        alignment: Alignment.topCenter,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('${day.day}', style: TextStyle(color: Colors.black),),
            ),
          ],
        )
    );
  }
  Widget selectedBuilder(context, day, selectedDay) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        alignment: Alignment.topCenter,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                //border: Border.all(color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('${day.day}', style: TextStyle(color: Colors.white),),
            ),
          ],
        )
    );
  }

  Widget markerBuilder(context, day, events) {
    if (appController.orderedMap[DateFormat.yM().format(day)] == null) {
      return SizedBox();
    }
    final nowEvent = appController.orderedMap[DateFormat.yM().format(day)]![day.day];

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
      child: SingleChildScrollView(
        child: SizedBox(
          height: 210,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: nowEvent.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  height: 50, //width: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 3,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(width: 3,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 37,
                            child: Text(
                              appController.appList[nowEvent[index]].userNick,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: (appController.appList[nowEvent[index]].userNick == widget.userName)? Colors.red : Colors.black
                              ),
                            ),
                          ),

                          Text(
                            DateFormat.Hm('ko_KR').format(appController.appList[nowEvent[index]].startTime),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),

                          Text(
                            '~${DateFormat.Hm('ko_KR').format(appController.appList[nowEvent[index]].endTime)}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
          ),
        ),
      ),
    );
  }
  Widget calendarWidget() {
    return TableCalendar(
      daysOfWeekHeight: 20,
      rowHeight: 270,

      calendarFormat: CalendarFormat.week,
      headerStyle: HeaderStyle(
        formatButtonVisible : false,
        titleTextFormatter: (date, locale) =>
            DateFormat.yMMM('ko_KR').format(date),
      ),

      focusedDay: (chatAppController.isAppointmentExisted.value && (chatAppController.appointmentTime.value.isAfter(DateTime.now())))? chatAppController.appointmentTime.value : DateTime.now(),
      firstDay: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDay: DateTime(DateTime.now().year + 2),

      onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;

          if (appController.orderedMap[DateFormat.yM().format(_selectedDay)] == null) {
            nowAppList = [];
          }
          else {
            nowAppList = appController.orderedMap[DateFormat.yM().format(_selectedDay)]![_selectedDay.day];
          }
        });
      },
      selectedDayPredicate: (DateTime day) {
        return isSameDay(_selectedDay, day);
      },

      calendarStyle: CalendarStyle(
        markersAlignment: Alignment.topCenter,
      ),
      calendarBuilders: CalendarBuilders(
        dowBuilder:      dowBuilder,
        defaultBuilder:  defaultBuilder,
        outsideBuilder:  outsideBuilder,
        todayBuilder:    todayBuilder,
        selectedBuilder: selectedBuilder,
        markerBuilder:   markerBuilder,
        disabledBuilder: disabledBuilder,
      ),
    );
  }
  Widget appointmentList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: nowAppList.length,
        itemBuilder: (context, index) {
          Appointment nowApp = appController.appList[nowAppList[index]];

          return Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(border: BorderDirectional(
                bottom: BorderSide(color: Colors.grey.shade100))),
            height: 60,
            child: Row(
              children: [
                // TODO 이거 유저 색깔 넣는거 추가 할 거 같은데 유저 에서 ID랑 nick 만 들어 와서 애매함
                Container(
                  height: 40,
                  width: 7,
                  decoration: BoxDecoration(color: Colors.orange,
                      borderRadius: BorderRadius.circular(5)),
                ),

                SizedBox(width: 10,),
                SizedBox(
                  width: 100,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 12,),
                      Text(DateFormat.jm('ko_KR').format(nowApp.startTime),
                        style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 20,
                            height: 1),),
                      Text(
                        '~ ${DateFormat.jm('ko_KR').format(nowApp.endTime)} 까지',
                        style: TextStyle(
                            color: Colors.black, fontSize: 12, height: 1),),
                    ],
                  ),
                ),
                SizedBox(width: 10,),
                Text('${nowApp.userNick}와의 약속',
                  style: TextStyle(fontSize: 20),),
              ],
            ),
          );
        }
    );
  }

  DateTime  _selectedDay     = DateTime.now();
  DateTime  _focusedDay      = DateTime.now();
  TimeOfDay selectedTime    = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    appController.getSimpleInformation();
    nowAppList = appController.orderedMap[DateFormat.yM().format(_selectedDay)]![_selectedDay.day];

    if (!chatAppController.isAppointmentExisted.value || chatAppController.isAppointmentDone.value) {
      chatAppController.initialDay = DateTime.now();
      chatAppController.initialTime = TimeOfDay.now();
      chatAppController.initialEndTime = TimeOfDay.now();
    }
    _selectedDay  = chatAppController.initialDay;
    selectedTime = chatAppController.initialTime;
    selectedEndTime = chatAppController.initialEndTime;

    //setState(() {});
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
                if ((!chatAppController.isAppointmentExisted.value) || chatAppController.isAppointmentDone.value) ...[
                  Text(
                    '${widget.userName}와 ${addDayTime(_selectedDay, selectedTime).toString()}에 정말 예약신청하겠습니까?',
                    style: TextStyle(fontWeight: FontWeight.bold),),
                ]
                else ...[
                  Text(
                    '${widget.userName}와 ${addDayTime(_selectedDay, selectedTime).toString()}으로 정말 예약수정하겠습니까?',
                    style: TextStyle(fontWeight: FontWeight.bold),),
                ],

              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final startTime = addDayTime(_selectedDay, selectedTime);
                final endTime = addDayTime(_selectedDay, selectedEndTime);

                if ((!chatAppController.isAppointmentExisted.value) || chatAppController.isAppointmentDone.value) {
                  chatAppController.makeAppointment(startTime, endTime);
                }
                else {
                  chatAppController.editAppointment(startTime, endTime);
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
                  '${widget.userName}와 ${addDayTime(_selectedDay, selectedTime).toString()}의 약속을 정말 삭제하시겠습니까?',
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                chatAppController.deleteAppointment();
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

  Widget selectButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (chatAppController.isAppointmentExisted.value && !chatAppController.isAppointmentDone.value) ... [
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
            if (selectedTime.isAfter(selectedEndTime)) {
              return;
            }
            setAppointmentAlert(context);
          },
          child: Text('결정', style: TextStyle(fontSize: 20, color: Colors.blue),)
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      builder: (BuildContext context, ScrollController scrollController) {
        return Wrap(children: [
          Container(
            height: 700,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  width: 200,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey),
                ),
                if ((!chatAppController.isAppointmentExisted.value) || chatAppController.isAppointmentDone.value) ...[
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
                Obx(() {
                  if (appController.isLoading.value) {
                    return Center(child: CircularProgressIndicator(),);
                  }
                  return calendarWidget();
                }),

                Row(
                  children: [
                    SizedBox(width: 11,),
                    Text('선택한 날짜', style: TextStyle(fontSize: 15),),
                    SizedBox(width: 28,),
                    Icon(CupertinoIcons.right_chevron, size: 17,),
                    SizedBox(width: 20,),
                    Text(DateFormat.yMMMd('ko_KR').format(_selectedDay), style: TextStyle(fontSize: 15),),
                  ],
                ),
                SizedBox(height: 5,),

                TextButton(
                  onPressed: () async {
                    final selectedTimeSub = await showTimePicker(
                      context: context,
                      initialTime: chatAppController.initialTime,
                    );
                    if (selectedTimeSub != null) {
                      setState(() {
                        selectedTime = selectedTimeSub;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Text('시작 시각 선택', style: TextStyle(fontSize: 15, color: Colors.black),),
                      SizedBox(width: 10,),
                      Icon(CupertinoIcons.right_chevron),
                      SizedBox(width: 20,),
                      Text('${selectedTime.hour.toString()} : ${selectedTime.minute.toString()}',
                        style: TextStyle(
                            fontSize: 15,
                            color: (selectedTime.isAfter(selectedEndTime)) ? Colors.red : Colors.black
                        ),
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () async {
                    final selectedTimeSub = await showTimePicker(
                      context: context,
                      initialTime: chatAppController.initialTime,
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
                      Text('완료 시각 선택', style: TextStyle(fontSize: 15, color: Colors.black),),
                      SizedBox(width: 10,),
                      Icon(CupertinoIcons.right_chevron),
                      SizedBox(width: 20,),
                      Text('${selectedEndTime.hour.toString()} : ${selectedEndTime.minute.toString()}',
                        style: TextStyle(
                            fontSize: 15,
                            color: (selectedTime.isAfter(selectedEndTime)) ? Colors.red : Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height:10),
                selectButton(),
              ],
            ),
          ),
        ],);
      }
    );
  }

}