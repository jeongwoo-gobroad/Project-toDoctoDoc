import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/careplus/appointment_controller.dart';
import 'package:to_doc/screens/appointment/appointment_detail_screen.dart';




class AppointmentListview extends StatefulWidget {
  const AppointmentListview({super.key, required this.appointmentController});
  
  final AppointmentController appointmentController;

  @override
  State<AppointmentListview> createState() => _AppointmentListviewState();
}

class _AppointmentListviewState extends State<AppointmentListview> with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  late TabController tabController = TabController(length: 2, vsync: this, initialIndex: 1, animationDuration: const Duration(milliseconds: 300));

  bool checkIfDayChanged(index) {
    if (index == 0) {
      return true;
    }
    if ((widget.appointmentController.appointmentList[index-1]['appointmentTime'].day != widget.appointmentController.appointmentList[index]['appointmentTime'].day)) {
      return true;
    }
    return false;
  }

  gotoDetainScreen(index) async {
    await widget.appointmentController.getAppointmentInformation(widget.appointmentController.appointmentList[index]['_id']);
    Get.to(()=>AppointmentDetailScreen(appointment: widget.appointmentController.appointment, hospital: widget.appointmentController.hospital, doctorName: widget.appointmentController.appointmentList[index]['doctor']['name']));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appointmentController.getAppointmentList();
    });

  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (widget.appointmentController.isLoading.value) {
          return;
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: InkWell(
              child: Text('예약 리스트(가)',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
            bottom: TabBar(controller: tabController, tabs: [Tab(text: '지나간 약속',), Tab(text: '남은 약속',)])
          ),
          body: TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: widget.appointmentController.nearAppointment,
                      itemBuilder: (context, index) {
                        final appointment = widget.appointmentController.appointmentList[index];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (checkIfDayChanged(index)) ... [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey.shade300),
                                      top: BorderSide(color: Colors.grey.shade300),
                                    )
                                ),
                                child: Text(DateFormat.yMMMEd('ko_KR').format(appointment['appointmentTime'])),
                              ),
                            ],

                            InkWell(
                              onTap: () {
                                gotoDetainScreen(index);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                //decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300),)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(DateFormat.jm('ko_KR').format(appointment['appointmentTime']), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                        SizedBox(width: 5),
                                        Text('${appointment['doctor']['name']}와의 약속' , style: TextStyle(fontSize: 20),),
                                      ],
                                    ),

                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: (appointment['hasAppointmentDone'])? Colors.green : Colors.grey,
                                        borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: Text('완료', style: TextStyle(color: Colors.white),),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                ],
              ),


              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: widget.appointmentController.appointmentList.length - widget.appointmentController.nearAppointment,
                        itemBuilder: (context, index) {
                          final appointment = widget.appointmentController.appointmentList[index + widget.appointmentController.nearAppointment];


                          if (!widget.appointmentController.appointmentList[index + widget.appointmentController.nearAppointment]['isAppointmentApproved']) {
                            //return SizedBox(height: 20, child: Text('미승인 약속입니다.'),);
                          }


                          return Column(
                            children: [
                              if (checkIfDayChanged(index + widget.appointmentController.nearAppointment)) ... [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Colors.grey.shade300),
                                        top: BorderSide(color: Colors.grey.shade300),
                                      )
                                  ),
                                  child: Text(DateFormat.yMMMEd('ko_KR').format(appointment['appointmentTime'])),
                                ),
                              ],

                              InkWell(
                                onTap: () {
                                  gotoDetainScreen(index + widget.appointmentController.nearAppointment);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                  //decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300),)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(DateFormat.jm('ko_KR').format(appointment['appointmentTime']), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                                          SizedBox(width: 5),
                                          Text('${appointment['doctor']['name']}와의 약속' , style: TextStyle(fontSize: 20),),
                                        ],
                                      ),

                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: (appointment['isAppointmentApproved'])? Colors.blue : Colors.grey,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Text('승인', style: TextStyle(color: Colors.white),),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );

                        }),
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }


}
