import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:to_doc/screens/careplus/appointment_rating_screen.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key, required this.appointment, required this.hospital, required this.doctorName});

  final Map<String, dynamic> appointment;
  final Map<String, dynamic> hospital;
  final String doctorName;

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late KakaoMapController kakaoMapController; //카카오 맵 컨트롤러러
  Set<Marker> markers = {};

  bool isradiusNotSelected = true;
  bool showMap = true;
  bool isDropdownOpen = false;

  List<CustomOverlay> customOverlays = [];

  Widget placeInform(BuildContext context, Icon thisIcon, String description) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            child: thisIcon,
          ),
          Container(
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
          child: Text('예약 정보',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        actions: <Widget>[

          if (DateTime.parse(widget.appointment['appointmentTime']).isBefore(DateTime.now())) ... [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10,),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: (widget.appointment['hasAppointmentDone'])? Colors.green : Colors.grey,
                  //border: Border.all(width: 3)
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Text('완료', style: TextStyle(color: Colors.white),),
            )
          ]
          else ... [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10,),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: (widget.appointment['isAppointmentApproved'])? Colors.blue : Colors.grey,
                  //border: Border.all(width: 3)
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Text('승인', style: TextStyle(color: Colors.white),),
            )
          ],

        ]
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 350,
              child: KakaoMap(
                onMapCreated: (controller) async {
                  kakaoMapController = controller;
                  markers.add(Marker(
                    markerId: 'myLocationMarker',
                    latLng: LatLng(widget.hospital['address']['latitude'], widget.hospital['address']['longitude']),
                    width: 50,
                    height: 45,
                  ));
                  setState(() {

                  });
                },
                markers: markers.toList(),
                center: LatLng(widget.hospital['address']['latitude'], widget.hospital['address']['longitude']),
              ),
            ),

            if (widget.appointment['hasAppointmentDone'] && !widget.appointment['hasFeedbackDone']) ... [
              Container(
                width: double.infinity,
                //margin: EdgeInsets.symmetric(vertical: 5),
                child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0))
                      ),
                      backgroundColor: Colors.green,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        builder: (_) {
                          return AppointmentRatingScreen(doctorName: widget.doctorName, appointmentId: widget.appointment['_id'] );
                        },
                      );
                    },
                    child: Text('이 약속에 대한 간단한 피드백을 적어주세요', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),)
                ),
              ),
            ],
            placeInform(context, Icon(Icons.home), widget.hospital['name']),
            placeInform(context, Icon(Icons.person), widget.doctorName),
            placeInform(context, Icon(CupertinoIcons.clock), DateFormat.yMMMEd('ko_KR').add_jm().format(DateTime.parse(widget.appointment['appointmentTime']))),
            Container(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('정보', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                  SizedBox(height: 5),

                  Text(widget.appointment['isAppointmentApproved'].toString()),
                  Text(widget.appointment['hasAppointmentDone'].toString()),
                  Text(widget.appointment['hasFeedbackDone'].toString()),
                ],
              ),
            ),
            SizedBox(height: 5),

            Container(
              child: Column(
                children: [
                  Text('예약 정보', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),

                  SizedBox(height: 5),

                  Text(widget.hospital['name'] ?? ''),
                  Text("${widget.hospital['address']['address']} ${widget.hospital['address']['detailAddress']} ${widget.hospital['address']['extraAddress']}"),
                  Text(widget.hospital['phone'] ?? ''),
                  Text(widget.hospital['address']['postcode'] ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
