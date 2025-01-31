import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/screens/careplus/appointment_rating_screen.dart';


class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key, required this.appointment, required this.hospital, required this.doctorName});

  final Map<String, dynamic> appointment;
  final Map<String, dynamic> hospital;
  final String doctorName;

  Widget placeInform(BuildContext context, Icon thisIcon, String description) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            //width: MediaQuery.of(context).size.width * 1 / 20,
            child: thisIcon,
          ),
          Container(
            //color: Colors.blue,
            width: MediaQuery.of(context).size.width * 3 / 4,
            child: Text(description),
          ),
        ],
      ),
    );
  }

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



            if (appointment['hasAppointmentDone'] && !appointment['hasFeedbackDone']) ... [
              TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      isScrollControlled: true,
                      builder: (_) {
                        return AppointmentRatingScreen(doctorName: doctorName, appointmentId: appointment['_id'] );
                      },
                    );
                  },
                  child: Text('RATING (UNFINISHED)')
              ),
            ],
            placeInform(context, Icon(Icons.home), hospital['name']),
            placeInform(context, Icon(Icons.person), doctorName),


            Container(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('정보', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                  SizedBox(height: 5),

                  //Text(appointment['_id'] ?? ''),
                  //Text(appointment['user'] ?? ''),
                  //Text(appointment['doctor']['_id'] ?? ''),
                  //Text(appointment['doctor']['myPsyID'] ?? ''),
                  Text(DateFormat.yMMMEd('ko_KR').add_jm().format(DateTime.parse(appointment['appointmentTime']))),
                  Text(appointment['isAppointmentApproved'].toString()),
                  Text(appointment['hasAppointmentDone'].toString()),
                  Text(appointment['hasFeedbackDone'].toString()),
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
