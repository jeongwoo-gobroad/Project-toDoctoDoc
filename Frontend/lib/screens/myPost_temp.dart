import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/myPost_controller.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/pageView.dart';


/** 스크롤 기능 구현 예정, 페이지로 나누기 */
class MypostTemp extends StatefulWidget {

  MypostTemp({super.key});

  @override
  State<MypostTemp> createState() => _MypostTempState();
}

class _MypostTempState extends State<MypostTemp> {
  final ViewController viewController = Get.put(ViewController());
  final MypostController controller = Get.put(MypostController());
  
  // _enterFeed() async{
  //   await viewController.getFeed(){

  // };


  @override
  void initState(){
    super.initState();
    controller.fetchMyPost();
  }

  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);

    return formattedDate;
  }
  
  Future<void> _onRefresh() async{
    await controller.fetchMyPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('data')),

      body: Obx((){
        if(controller.isLoading.value){
          return Center(child: CircularProgressIndicator());
        }
        if(controller.posts.isEmpty){
          return Center(
           child: Text('게시물이 없습니다.'),
          );
        }
        return NotificationListener<ScrollNotification>( //스크롤구현
          
          
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                itemCount: controller.posts.length,
                itemBuilder: (context, index){
                  final post = controller.posts[index];
                  return ListTile(
                    onTap: () async{
              
                      await viewController.getFeed(controller.posts[index]['_id']);
                      Get.to(()=> Pageview());
              
                    },
                    title: Text(post['title'] ?? '제목없음'), //post['title']
                    subtitle: Text('태그: ${post['tag']}' ?? ''),
                    trailing: Text(formatDate(post['createdAt']) ?? ''), //2025년 10시 17분
                  );
              
                },
              ),
            ),
          
        );
      }),
    );
  }
}