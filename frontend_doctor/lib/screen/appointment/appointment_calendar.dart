import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';

class AppointmentCalendar extends StatefulWidget {
  const AppointmentCalendar({super.key});

  @override
  State<AppointmentCalendar> createState() => _AppointmentCalendarState();
}

class _AppointmentCalendarState extends State<AppointmentCalendar> {
  AppointmentController appController = Get.find<AppointmentController>();
  List<int> nowAppList = [];

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

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
      child: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: (nowEvent.length > 3) ? 3 : nowEvent.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  height: 20, width: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(width: 5,),
                      SizedBox(
                        width: context.width / 7 - 14,
                        child: Text(
                          appController.appList[nowEvent[index]].userNick,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, height: 1),
                        ),
                      ),
                    ],
                  ),
                );
              }
          ),

          if (nowEvent.length > 3) ... [
            Icon(Icons.more_vert, size: 15,),
          ],
        ],
      ),
    );
  }
  Widget calendarWidget() {
    return TableCalendar(
      daysOfWeekHeight: 20,
      rowHeight: 150,

      calendarFormat: CalendarFormat.twoWeeks,
      headerStyle: HeaderStyle(
        titleTextFormatter: (date, locale) =>
            DateFormat.yMMM('ko_KR').format(date),
        formatButtonVisible : false,
      ),

      focusedDay: DateTime.now(),
      firstDay: DateTime(2024),
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
        dowBuilder: dowBuilder,
        defaultBuilder: defaultBuilder,
        outsideBuilder: outsideBuilder,
        todayBuilder: todayBuilder,
        selectedBuilder: selectedBuilder,
        markerBuilder: markerBuilder,
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

  @override
  void initState() {
    super.initState();
    nowAppList = appController.orderedMap[DateFormat.yM().format(_selectedDay)]![_selectedDay.day];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 일정'),
      ),
      body: Column(
        children: [
          calendarWidget(),
          SizedBox(height: 20,),
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat.yMMMd('ko_KR').format(_selectedDay)}',
                  style: TextStyle(fontSize: 20),
                ),

                if (nowAppList.isEmpty) ... [
                  SizedBox(height: 50,),
                  Center(child: Text('약속이 없습니다.', style: TextStyle(fontSize: 20),))
                ]
                else ... [
                  SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 521,
                      child: appointmentList()
                    ),
                  )
                ]
              ],
            ),
          ),
        ],
      )
    );
  }
}
