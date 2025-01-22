import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/myPost_controller.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/view_controller.dart';

/**
 * 수정가능 field는 addcontent, tag뿐뿐
 */
class PageEdit extends StatefulWidget {
  final ViewController model;
  const PageEdit(this.model, {super.key});

  @override
  State<PageEdit> createState() => _PageEditState();
}

class _PageEditState extends State<PageEdit> {
  final TextEditingController _additionalMaterialController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final MypostController mypostController = Get.put(MypostController(dio: Dio()));
  final ViewController viewController = Get.put(ViewController(dio:Dio()));

  _submit() async{
    String updatedAdditionalMaterial = _additionalMaterialController.text;
    String updatedTag = _tagController.text;

    if (updatedAdditionalMaterial.isEmpty || updatedTag.isEmpty) {
      Get.snackbar('Error', '모든 필드를 채워주세요.');
      return;
      
    }
    viewController.additional_material.value = updatedAdditionalMaterial;
    viewController.tag.value = updatedTag;
    
    await mypostController.editMyPost(
      widget.model.currentId.value,
      
      updatedAdditionalMaterial,
     
      updatedTag,
    );
    
    await viewController.getFeed(widget.model.currentId.value);

    Navigator.pop(context);


  }
  @override
  void initState() { //바로 전의 값을 채워주기위함.
    
    super.initState();
    _additionalMaterialController.text = widget.model.additional_material.value;
    _tagController.text = widget.model.tag.value;

  }
 
  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date).toLocal();
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);

    return formattedDate;


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('수정하기'), //수정하기
        centerTitle: true,
         actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submit,
          ),
         ],
      
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
                    Text(widget.model.title.value, 
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
                          widget.model.tag.value,
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
                Text(widget.model.usernick.value,
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
                Text(formatDate(widget.model.createdAt.value),
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
                    Text(formatDate(widget.model.editedAt.value),
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
                     widget.model.details.value,
                     style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 41, 41, 41),
                     ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                        controller: _additionalMaterialController,
                        decoration: InputDecoration(
                          labelText: '추가 내용',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                         ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          labelText: '태그',
                          border: OutlineInputBorder(),
                        ),
                      ),


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