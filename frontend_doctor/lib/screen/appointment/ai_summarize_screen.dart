import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/controllers/AIassistant/ai_assistant_controller.dart';
import 'package:to_doc_for_doc/controllers/appointment_controller.dart';

class AiSummarizeScreen extends StatefulWidget {
  const AiSummarizeScreen({super.key});

  @override
  State<AiSummarizeScreen> createState() => _AiSummarizeScreenState();
}

class _AiSummarizeScreenState extends State<AiSummarizeScreen> {
  AiAssistantController aiController = Get.put(AiAssistantController());
  AppointmentController appController = Get.find<AppointmentController>();

  String todayYM = DateFormat.yM().format(DateTime.now());
  int today = DateTime.now().day;

  void asyncBefore() async {
    aiController.loadDailySummary();
    await aiController.assistantDailyLimit();
    setState(() {});
  }

  @override
  void initState() {
    asyncBefore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 1.0,
      minChildSize: 0.4,
      builder: (BuildContext context, ScrollController scrollController) {
        return Wrap(children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height/2,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('AI 요약', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),

                      Obx(() {
                        if (aiController.isLoading.value) {
                          return Center(child: CircularProgressIndicator(),);
                        }
                        if (!aiController.isDailySumExist.value) {
                          return Text(aiController.dailySummary.value);
                        }
                        return Expanded(
                          child: ListView.builder(
                            itemCount: aiController.dailySumMap['appointments'].length,
                            itemBuilder: (context, index) {
                              final thisApp = aiController.dailySumMap['appointments'][index];
                              return Column(
                                children: [
                                  Text(thisApp['patientName']),
                                  //Text(DateFormat.jm('ko_KR').format(DateTime.parse(thisApp['startfrom']))),
                                  Text(thisApp['shortMemo']),
                                ],
                              );
                            }
                          ),
                        );
                      }),
                    ],
                  )
                ),


                Container(
                  decoration: BoxDecoration(
                    color: (aiController.isDailySumRemain.value && (appController.isTodayAppExist.value))? Colors.blue : Colors.grey,
                  ),
                  child: TextButton(
                    onPressed: (!appController.isTodayAppExist.value || !aiController.isDailySumRemain.value) ? null : () async  {
                      await aiController.dailySummation();
                      setState(() {});
                    },
                    style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.bottomRight,
                      //textStyle: TextStyle(color: Colors.white),
                    ),
                    child: Container(
                      //padding: EdgeInsets.symmetric(horizontal: 5),
                      width: 170,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white,),
                          Text(' 요약 업데이트 ', style: TextStyle(fontSize: 20, color: Colors.white),),
                          Text('${aiController.dailySumCount.value}/${aiController.dailySumLimit}', style: TextStyle(fontSize: 15, color: Colors.white),),
                        ],
                      ),
                    )
                  ),
                ),

                SizedBox(height: 10,),
              ],
            ),
          )
        ],);
      }
    );
  }
}