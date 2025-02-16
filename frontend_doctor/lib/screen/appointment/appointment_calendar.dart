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

  @override
  void initState() {
    nowAppList = appController.orderedMap[DateFormat.yM().format(_selectedDay)]![_selectedDay.day];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 일정'),
      ),
      body: Column(
        children: [
          TableCalendar(
            daysOfWeekStyle: DaysOfWeekStyle(
              // TODO 세팅 해야함

            ),
            calendarFormat: CalendarFormat.twoWeeks,
            headerStyle: HeaderStyle(
              titleTextFormatter: (date, locale) => DateFormat.yM('ko_KR').format(date),
            ),
            focusedDay: DateTime.now(),
            firstDay:   DateTime(2024),
            lastDay:    DateTime(DateTime.now().year+2),

            onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
              setState((){
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

            rowHeight: 150,

            calendarStyle: CalendarStyle(
                markersAlignment: Alignment.topCenter,

            ),
            calendarBuilders: CalendarBuilders(

              dowBuilder: (context, day) {
                if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
                  final text = DateFormat.E('ko').format(day);
                  return Center(
                    child: Text(
                      text,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
              },
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.topCenter,
                    child: Text('${day.day}')
                );
              },
              outsideBuilder: (context, day, focusedDay) {
                return Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.topCenter,
                    child: Text('${day.day}', style: TextStyle(color: Colors.grey),)
                );
              },
              todayBuilder: (context, day, selectedDay) {
                return Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    alignment: Alignment.topCenter,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text('${day.day}', style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    )
                );
              },
              selectedBuilder: (context, day, selectedDay) {
                return Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    alignment: Alignment.topCenter,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text('${day.day}', style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    )
                );
              },


              markerBuilder: (context, day, events) {
                //if (day == _selectedDay) return SizedBox();

                if (appController.orderedMap[DateFormat.yM().format(day)] == null) {
                  return SizedBox();
                }

                final nowEvent = appController.orderedMap[DateFormat.yM().format(day)]![day.day];

                return Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: nowEvent.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: (day == _selectedDay) ? Colors.white : Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 10, width: 10,
                        );
                      }
                  ),
                );
              }
            ),

          ),

          SizedBox(height: 20,),

          Container(
            child: Column(
              children: [
                Text('${DateFormat.yMd().format(_selectedDay)}'),

                if (nowAppList.isEmpty) ... [
                  Text('약속이 없습니다.')
                ]
                else ... [

                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: nowAppList.length,
                      itemBuilder: (context, index) {
                        Appointment nowApp = appController.appList[nowAppList[index]];

                        return Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(color: Colors.grey.shade100))),
                          height: 60,
                          child: Row(
                            children: [
                              // TODO 이거 유저 색깔 넣는거 추가 할 거 같은데 유저 에서 ID랑 nick 만 들어 와서 애매함
                              Container(
                                height: 40,
                                width: 7,
                                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(5)),
                              ),

                              SizedBox(width: 10,),
                              SizedBox(
                                width: 100,
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 12,),
                                    Text(DateFormat.jm('ko_KR').format(nowApp.startTime),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, height: 1),),
                                    Text('~ ${DateFormat.jm('ko_KR').format(nowApp.endTime)} 까지',
                                      style: TextStyle(color: Colors.black, fontSize: 12, height: 1),),
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


                  )
                ]

              ],
            ),
          )



        ],
      )
    );
  }
}
