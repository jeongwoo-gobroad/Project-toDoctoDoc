import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/chat_controller.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_controller.dart';
import 'package:to_doc_for_doc/screen/patient_manage/memo_main.dart';
import 'package:to_doc_for_doc/screen/patient_manage/memo_write.dart';

class PatientManageMain extends StatefulWidget {
  const PatientManageMain({super.key});

  @override
  State<PatientManageMain> createState() => _PatientManageMainState();
}

class _PatientManageMainState extends State<PatientManageMain> {
  final ChatController controller = Get.put(ChatController());
  final MemoController memoController = Get.put(MemoController());
  final RxList selectedPatients = [].obs;

  @override
  void initState() {
    controller.getChatList();
    super.initState();
  }

  void _showPatientListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '환자 목록',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // //검색용
                // TextField(
                //   decoration: InputDecoration(
                //     hintText: '환자 검색',
                //     prefixIcon: Icon(Icons.search),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //   ),
                // ),
                // SizedBox(height: 20),
                // 환자 목록
                Obx(
                  () => Expanded(
                    child: ListView.separated(
                      itemCount: controller.chatList.length, // 샘플 데이터 수
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        final chat = controller.chatList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 225, 234, 205),
                            child: Text('${index + 1}'),
                          ),
                          title: Text('${chat.userName}'),
                          subtitle: Text('샘플텍스트'),
                          trailing: IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              if (!selectedPatients.any(
                                  (patient) => patient['id'] == chat.userId)) {
                                selectedPatients.add({
                                  'id': chat.userId,
                                  'name': chat.userName,
                                });
                              }

                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('환자 관리'),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.help_outline),
      //       onPressed: () {},
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text('환자 추가'),
                      onPressed: () => _showPatientListDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 225, 234, 205),
                        foregroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    Obx(() => Text(
                          '환자 수: ${selectedPatients.length}명',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
                SizedBox(height: 20),

                // 추가한 환자를 Card모양으로 여기다가 삽입입
                Expanded(
                  child: Obx(() => GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 5,
                          childAspectRatio: 5,
                        ),
                        itemCount: selectedPatients.length,
                        itemBuilder: (context, index) {
                          final patient = selectedPatients[index];
                          return InkWell(
                            onTap: () async {
                              bool exists = await memoController
                                  .memoExists(patient['id']);
                              if (!exists) {
                                bool? confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('메모 작성'),
                                      content:
                                          Text('환자에 대한 메모가 없습니다. 작성하러 가시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text('확인'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirmed == true) {
                                  Get.to(() => MemoWriteScreen(
                                      patientId: patient['id']));
                                }
                              } else{
                                //수정화면 이동 
                                // Get.to(() => MemoWriteScreen(
                                //       patientId: patient['id']));
                                Get.to(() => MemoMain());
                                await memoController.getMemoList();
                                
                              }
                             
                            },
                            child: Card(
                              elevation: 4,
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patient['name'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: IconButton(
                                      icon: Icon(Icons.close, size: 20),
                                      onPressed: () {
                                        selectedPatients.removeAt(index);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
