import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/query_controller.dart';
import 'package:to_doc/screens/result_edit.dart';

class Airesult extends StatelessWidget {

  Airesult({super.key});
  final QueryController queryController = Get.put(QueryController());

 @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (queryController.isLoading.value) {
        // 로딩 상태일 때
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('답변 생성 중...'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        // 정상 상태일 때
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('공유하기'),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.black, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        queryController.title.value,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        queryController.context.value,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 10),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          ),
                          onPressed: () {
                            Get.to(()=> ResultEdit());
                            // 게시판공유
                          },
                          child: Text(
                            '내가 걱정을 이겨낸 방법을 공유하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ),
        );
      }
    });
  }
}












