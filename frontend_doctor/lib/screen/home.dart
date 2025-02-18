import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';
import 'package:to_doc_for_doc/controllers/curate/curate_controller.dart';
import 'package:to_doc_for_doc/screen/appointment/ai_summarize_screen.dart';
import 'package:to_doc_for_doc/screen/appointment/appointment_calendar.dart';
import 'package:to_doc_for_doc/screen/appointment/appointment_listview.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CurateController curateController = Get.put(CurateController());
  AppointmentController appController = Get.put(AppointmentController());
  ScrollController scrollController = ScrollController();

  String todayYM = DateFormat.yM().format(DateTime.now());
  int today = DateTime.now().day;

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toUtc().add(Duration(hours: 9));
      return DateFormat.yMd('ko_KR').add_Hm().format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }

  showSimplifySheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return AiSummarizeScreen();
      },
    );
  }

  makeAppointmentList() {
    if (appController.isLoading.value) {
      return Center(child: CircularProgressIndicator(),);
    }
    return ListView.builder(
      shrinkWrap: true,
      controller: scrollController,
      itemCount: (!appController.isTodayAppExist.value) ? 0 : appController.orderedMap[todayYM]?[today].length,
      itemBuilder: (context, index) {
        var nowApp = appController.appList[appController.orderedMap[todayYM]![today][index]];

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
      },
    );
  }

  asyncBefore() async {
    await appController.getSimpleInformation();
    setState(() {});
  }

  @override
  void initState() {
    asyncBefore();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        centerTitle: true,
        title: Text('토닥toDoc - Doctor',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          showSimplifySheet();
        },
        //heroTag: "actionButton",
        backgroundColor: Color.fromARGB(255, 225, 234, 205),
        child: Icon(Icons.auto_awesome, color: Colors.lightBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx (() {
              if (appController.isLoading.value) {
                return Center(child: CircularProgressIndicator(),);
              }
              if (appController.isBeforeAppExist) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: MediaQuery.of(context).size.width - 20,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            //onTaptoGo();
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month),
                                    Text('최근에 약속이 있었어요', style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text('${appController.appList[appController.nearAppointment-1].userNick}, '
                                    '${DateFormat.yMMMEd('ko_KR').add_jm()
                                    .format(appController.appList[appController.nearAppointment-1].startTime)}'),

                              ],
                            ),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            appController.isLoading.value = true;
                            Get.to(()=>AppointmentListview());
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 50, 20, 0),
                            width: MediaQuery.of(context).size.width - 320,
                            decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('더보기', style: TextStyle(
                                    color: Colors.grey, fontSize: 10),),
                                Icon(Icons.arrow_forward_ios,
                                  color: Colors.grey.shade100,
                                  size: 10,),
                              ],
                            ),
                          ),
                        ),
                      ]
                  ),
                );
              }
              else {
                return SizedBox();
              }
            }),

            SizedBox(height: 10,),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  //border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
                      decoration: BoxDecoration(
                        border: BorderDirectional(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('오늘의 예약', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                            IconButton(
                              onPressed: () {
                                Get.to(() => AppointmentCalendar());
                              },
                              icon: Icon(Icons.calendar_month)
                            ),
                          ],
                        ),
                    ),

                    makeAppointmentList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
