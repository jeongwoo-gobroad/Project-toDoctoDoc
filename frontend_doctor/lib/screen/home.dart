import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/curate/curate_controller.dart';
import 'package:to_doc_for_doc/screen/curate/curate_detail_screen.dart';
import 'screen/dm_list.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CurateController curateController = Get.put(CurateController(dio: Dio()));

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toUtc().add(Duration(hours: 9));
      return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }
  @override
  void initState() {
    curateController.getCurateInfo('5');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => DMList());
        },
        child: const Icon(Icons.chat_bubble_outline_rounded),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('토닥toDoc - Doctor',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Text(
                    '디가오는 예약',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  //내 병원정보 부분분
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(
                          '내 병원정보',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(
                          '나의 처방전',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SizedBox(
                        height: 200,
                        child: Obx(() => curateController.forHomeLoading.value ? Center(child: CircularProgressIndicator(),)
                       : ListView.builder(
                              itemCount: curateController
                                  .sortedAndFilteredItems.length,
                              itemBuilder: (context, index) {
                                final item = curateController
                                    .sortedAndFilteredItems[index];
                                return InkWell(
                                  onTap: () async {
                                    await curateController
                                        .getCurateDetails(item.id);
                                    Get.to(() => CurateDetailScreen());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.users.map((user) => user.userNick).join(", ")}님의 큐레이팅 요청',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          formatDate(item.date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Divider(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
