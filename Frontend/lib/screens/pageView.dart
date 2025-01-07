import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:to_doc/controllers/myPost_controller.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/page_edit.dart';

class Pageview extends StatelessWidget {
  Pageview({super.key});
  ViewController viewController = Get.put(ViewController());
  MypostController mypostController = Get.put(MypostController());
    /*title.value = data['content']['title'];
      details.value = data['content']['details'];
      additional_material = data['content']['additional_material'];
      createdAt = data['content']['createdAt'];
      editedAt = data['content']['editedAt'];
      tag = data['content']['tag'];
      usernick = data['content']['usernick']; */

  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);

    return formattedDate;


  }
  List<Widget> buildTagChips(String tags) {
  List<String> tagList = tags.split(',').map((tag) => tag.trim()).toList();
  return tagList
      .map(
        (tag) => Chip(
          label: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      )
      .toList();
  }
  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(viewController.title.value, overflow: TextOverflow.ellipsis),
      actions: [
        PopupMenuButton(
          borderRadius: BorderRadius.circular(16),
          itemBuilder: (context) => <PopupMenuEntry>[
            PopupMenuItem(
              onTap: () {
                Get.to(() => PageEdit(viewController));
              },
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('수정하기'),
              ),
            ),
            PopupMenuItem(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('삭제하기'), //삭제하기
                      content: Text('이 글을 삭제하시겠습니까? 삭제한 글은 다시 볼 수 없습니다.'),
                      actions: [
                        ElevatedButton(
                          onPressed: () async {
                            bool result =
                                await mypostController.deleteMyPost(viewController.currentId.value);
                            if (result) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('확인'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('취소'),
                        )
                      ],
                    );
                  },
                );
              },
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('삭제하기'),
              ),
            ),
          ],
          icon: Icon(Icons.more_vert),
        ),
      ],
      centerTitle: true,
    ),
    body: Obx(
      () => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카드 섹션 (제목 + 태그)
              Card(
                elevation: 2,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewController.title.value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 8),
                      if (viewController.tag.value.isNotEmpty && 
                        viewController.tag.value.trim().isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: buildTagChips(viewController.tag.value),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4),
              // 작성자 정보 및 시간
              Center(
            
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            viewController.usernick.value,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            formatDate(viewController.createdAt.value),
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          )
                        ],
                      ),
                      if (true)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                formatDate(viewController.editedAt.value),
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4),
              
              Card(
                elevation: 2,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewController.details.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 41, 41, 41),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        viewController.additional_material.value,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5, 
                          color: const Color.fromARGB(255, 41, 41, 41),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}