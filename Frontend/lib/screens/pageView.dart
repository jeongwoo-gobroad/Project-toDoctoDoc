import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/myPost_controller.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/page_edit.dart';

class Pageview extends StatelessWidget {
  Pageview({super.key});
  final ViewController viewController = Get.find<ViewController>();
  MypostController mypostController = Get.put(MypostController());
  UserinfoController userinfoController = Get.find<UserinfoController>();
    /*title.value = data['content']['title'];
      details.value = data['content']['details'];
      additional_material = data['content']['additional_material'];
      createdAt = data['content']['createdAt'];
      editedAt = data['content']['editedAt'];
      tag = data['content']['tag'];
      usernick = data['content']['usernick']; */

  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date).toLocal();
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);

    return formattedDate;
  }

  List<Widget> buildTagChips(String tags) {
  List<String> tagList = tags.split(',').map((tag) => tag.trim()).toList();

  return tagList
      .map(
        (tag) => Chip(
          label: Text(
            '#$tag',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              decoration: TextDecoration.underline,
            ),
          ),
          backgroundColor: Colors.white,
          shape: const StadiumBorder(side: BorderSide(style: BorderStyle.none)),
          padding: EdgeInsets.all(0),
          labelPadding: EdgeInsets.fromLTRB(0, 0, 3, 0),
        ),
      )
      .toList();
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    //backgroundColor: Color.fromRGBO(244, 242, 248, 20),
    appBar: AppBar(
      //title: Text(viewController.title.value, overflow: TextOverflow.ellipsis),
      actions: [
        PopupMenuButton(
          borderRadius: BorderRadius.circular(16),
          itemBuilder: (context) => <PopupMenuEntry>[
            PopupMenuItem(
              onTap: () {
                if(viewController.uid != userinfoController.uid){
                  Get.snackbar('Error', '본인 게시물이 아닙니다.');
                }
                else{
                  Get.to(() => PageEdit(viewController));
                }
              },
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('수정하기'),
              ),
            ),
            PopupMenuItem(
              onTap: () {
                if(viewController.uid != userinfoController.uid){
                  Get.snackbar('Error', '본인 게시물이 아닙니다.');
                  
                }
                else{
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
                }
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
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(

                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black.withAlpha(50))),
                  color: Colors.white,),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 20, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            viewController.usernick.value,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),

                      Column(
                       children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              formatDate(viewController.createdAt.value),
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            )
                          ],
                        ),
                        if (true)
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 12, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  formatDate(viewController.editedAt.value),
                                  style: TextStyle(color: Colors.grey, fontSize: 10),
                                )
                              ],
                            ),
                          ),

                       ]),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 4),

              // 카드 섹션 (제목 + 태그)
              Card(
                elevation: 0,
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewController.title.value,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),

                      if (viewController.tag.value.isNotEmpty &&
                          viewController.tag.value.trim().isNotEmpty) ...[
                        Wrap(
                          spacing: 0.0,
                          runSpacing: 0.0,
                          children: buildTagChips(viewController.tag.value),
                        ),
                      ],

                      SizedBox(height: 8),

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
              // 작성자 정보 및 시간

              /* Card(
                color: Colors.white,
                elevation: 0,
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
              ),*/
            ],
          ),
        ),
      ),
    ),
  );
}

}