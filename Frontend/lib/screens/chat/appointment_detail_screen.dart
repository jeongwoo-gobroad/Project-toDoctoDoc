import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key, required this.appointment, required this.hospital});

  final Map<String, dynamic> appointment;
  final Map<String, dynamic> hospital;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          child: Text('예약 정보(가)',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('정보', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                SizedBox(height: 5),

                Text(appointment['_id'] ?? ''),
                Text(appointment['user'] ?? ''),
                Text(appointment['doctor']['_id'] ?? ''),
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


                Text(hospital['address']['longitude'].toString()),
                Text(hospital['address']['latitude'].toString()),

              ],
            ),
          ),
        ],


      ),


    );
  }
}
