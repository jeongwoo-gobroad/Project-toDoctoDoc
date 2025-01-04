import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/app.dart';



class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  MypostController mypostController = Get.put(MypostController());


  List<Map> posts = 
    [
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다2",
        "content" : "그러시군요2",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },
      {
        "title" : "마음이 아프다",
        "content" : "그러시군요",
      },


    ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPost'),
        centerTitle: true,
        
      ),
      body: Center(
        child: buildPosts(posts),


      ),

    );

  }
  Widget buildPosts(List<Map> posts) => ListView.builder(
    itemCount: posts.length,
    itemBuilder: (context, index){
      final post = posts[index];

      return InkWell(
        onTap: ()async {await mypostController.fetchMyPost();},

        child: ListTile(
          title: Text(post['title']),

        )
      );
    },
    
  ); //동적처리
}