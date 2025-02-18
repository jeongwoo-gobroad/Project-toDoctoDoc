import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/AIassistant/ai_assistant_controller.dart';

class AiSummarizeScreen extends StatefulWidget {
  const AiSummarizeScreen({super.key});

  @override
  State<AiSummarizeScreen> createState() => _AiSummarizeScreenState();
}

class _AiSummarizeScreenState extends State<AiSummarizeScreen> {
  AiAssistantController aiController = Get.put(AiAssistantController());

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
            height: 410,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
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
                    color: (aiController.isDailySumRemain.value)? Colors.blue : Colors.grey,
                  ),
                  child: TextButton(
                    onPressed: () async  {
                      if (!aiController.isDailySumRemain.value) {
                        return;
                      }

                      await aiController.dailySummation();
                      setState(() {});
                    },
                    style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.bottomRight,
                      //textStyle: TextStyle(color: Colors.white),


                    ),
                    child: SizedBox(
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white,),
                          Text('새 요약 받기', style: TextStyle(fontSize: 20, color: Colors.white),),
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