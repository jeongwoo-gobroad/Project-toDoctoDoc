// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:flutter/services.dart';
//
//
// setAppointmentDay() {
//   bool isSelected = false;
//
//   return Wrap(
//     children: [
//       Container(
//         //height: 300, // 모달 높이 크기
//           margin: const EdgeInsets.only(
//             left: 25,
//             right: 25,
//             bottom: 100,
//           ), // 모달 좌우하단 여백 크기
//           decoration: const BoxDecoration(
//             color: Colors.white, // 모달 배경색
//             borderRadius: BorderRadius.all(
//               Radius.circular(20), // 모달 전체 라운딩 처리
//             ),
//           ),
//
// /*          child: Wrap(
//             children: [*/
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//
//
//                   Text('약속 잡기',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                     ),
//                   ),
//
//                   TableCalendar(
//                     rowHeight: 50,
//                     locale: 'ko_KR',
//                     firstDay: DateTime.now(),
//                     lastDay: DateTime.utc(2030, 3, 14),
//                     focusedDay: DateTime.now(),
//
//                     headerStyle: HeaderStyle(
//                       titleCentered: true,
//                       formatButtonVisible: false,
//                       titleTextStyle: const TextStyle(
//                         fontSize: 15,
//                         color: Colors.blue,
//                       ),
//                     ),
//
//                     calendarStyle: CalendarStyle(
//                       selectedDecoration: BoxDecoration(
//                         color: Colors.blue,
//                         shape: BoxShape.circle,
//                       ),
//                       cellMargin: EdgeInsets.all(0),
//                       cellPadding: EdgeInsets.all(0),
//                     ),
//
//                     daysOfWeekHeight: 40,
//                     daysOfWeekStyle: DaysOfWeekStyle(
//                       weekdayStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                       weekendStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//
//                   if (isSelected) ...[
//                     TextButton(onPressed: () {}, child: Text('test'),),
//                   ],
//
//
//
//                   Row(
//                     children:[
//                       TextButton(onPressed: () {
//
//                       }, child: Text('no')),
//                       TextButton(onPressed: () {}, child: Text('yes')),
//                     ],
//                   ),
//                 ],
//               ),
// /*            ],
//           )*/
//       ),
//     ],
//   );
//
//
// }