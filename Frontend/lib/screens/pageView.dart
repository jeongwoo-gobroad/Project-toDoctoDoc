import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/myPost_controller.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/view_controller.dart';

class Pageview extends StatelessWidget {
  Pageview({super.key});
  ViewController viewController = Get.put(ViewController());

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(viewController.title.value, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(onPressed: (){
            //수정, 삭제 버튼 구현
          }, icon: Icon(Icons.more_vert)),
        ],
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                
                child: Card(
                  elevation: 2,
                  child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(viewController.title.value, 
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 8),
                  

                        //태그 존재
                    if(true)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey,
        
                          borderRadius: BorderRadius.circular(12),
                          
                        ),
                        child: Text(
                          viewController.tag.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                
                  ),
                ),
              
              ),

            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey),
                Text(viewController.usernick.value,
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
                Text(formatDate(viewController.createdAt.value),
                style: TextStyle(color: Colors.grey,  fontSize: 13),
                )
                //formatDate(viewController.createdAt.value)
              ]
            ),
            //수정이 된경우?
            if(true)
              Padding(
                padding: EdgeInsets.only(top:4),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text("123412",
                    style: TextStyle(color: Colors.grey,  fontSize: 13),
                    )
                    //formatDate(viewController.createdAt.value)
                  ],
                ),
              ),


            Card(
              elevation: 2,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //내용
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
                        height: 15,
                        color: const Color.fromARGB(255, 41, 41, 41),
                      ),
                    )



                  ],


                ),


              ),



            )



            ],
            










          ),
        ),
        



      )
            








    );
  }
}