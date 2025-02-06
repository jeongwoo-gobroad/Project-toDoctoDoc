import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/navigator/side_menu.dart';
import 'package:to_doc/screens/careplus/curate_feed.dart';

@deprecated
class CurationHomeScreen extends StatelessWidget {

  CurateListController curateListController = Get.put(CurateListController());
  UserinfoController userinfoController = Get.find<UserinfoController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Obx(() => SideMenu(
          userinfoController.usernick.value,
          userinfoController.email.value
        )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(),
              onPressed: (){Get.to(CurateFeed());},
              child: Text('목록'),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
             
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      title: const Text(
                        "큐레이팅 요청",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      content: const Text(
                        "주치의 큐레이팅 시스템을 활용하기 위해 본인의 AI 기반 고민 상담 기록을 제출하는 것에 동의합니다.",
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); //팝업닫기
                          },
                          child: const Text(
                            "취소",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async{
                            Navigator.of(context).pop(); 
                            await curateListController.requestCurate();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: const Text("확인"),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[900], 
                shape: const CircleBorder(), 
                padding: const EdgeInsets.all(50), 
                shadowColor: Colors.black,
                elevation: 8, 
              ),
              child: const Text(
                "큐레이팅 받기",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
