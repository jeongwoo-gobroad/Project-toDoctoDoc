import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key, required this.appointment, required this.hospital, required this.doctorName});

  final Map<String, dynamic> appointment;
  final Map<String, dynamic> hospital;
  final String doctorName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          child: Text('예약 정보(가)',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            //TODO 여기 지도 넣어야 함
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(color: Colors.black),
              child: Text('${hospital['address']['longitude'].toString()}\n${hospital['address']['latitude'].toString()}',
              style: TextStyle(color: Colors.white),),
            ),


            Container(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('정보', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                  SizedBox(height: 5),

                  Text(appointment['_id'] ?? ''),
                  Text(appointment['user'] ?? ''),
                  Text(appointment['doctor']['_id'] ?? ''),
                  Text(doctorName),
                  Text(appointment['doctor']['isPremiumPsy'].toString()),
                  Text(appointment['doctor']['myPsyID'] ?? ''),
                  Text(DateFormat.yMMMEd('ko_KR').add_jm().format(DateTime.parse(appointment['appointmentTime']))),
                  Text(appointment['isAppointmentApproved'].toString()),
                  Text(appointment['appointmentCreatedAt'] ?? ''),
                  Text(appointment['appointmentEditedAt'] ?? ''),
                ],
              ),
            ),
            SizedBox(height: 5),

            Container(

              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('예약 정보', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                  SizedBox(height: 5),

                  Text(hospital['name'] ?? ''),
                  Text("${hospital['address']['address']} ${hospital['address']['detailAddress']} ${hospital['address']['extraAddress']}"),
                  Text(hospital['phone'] ?? ''),
                  Text(hospital['address']['postcode'] ?? ''),
                ],
              ),
            ),
          ],


        ),
      ),


    );
  }
}
