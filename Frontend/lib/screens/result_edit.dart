import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/query_controller.dart';
import 'package:to_doc/controllers/upload_controller.dart';
import 'package:to_doc/screens/myPost.dart';

class ResultEdit extends StatefulWidget {
  const ResultEdit({super.key});

  @override
  State<ResultEdit> createState() => _ResultEditState();
}

class _ResultEditState extends State<ResultEdit> {
  QueryController queryController = Get.put(QueryController());
  final FocusNode focusNode = FocusNode();
  bool isExpanded = false;
  UploadController uploadController = Get.put(UploadController());
                        

  final TextEditingController addController = TextEditingController(); //추후 수정
  final TextEditingController tagController = TextEditingController(); //추후 수정

  _submit() async{
    await uploadController.uploadResult(
      queryController.title.value, 
      queryController.context.value,
      addController.text,
      tagController.text,
    );
    Get.to(()=> MyPage());
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('공유하기')),
      body: SingleChildScrollView(
        //padding: EdgeInsets.all(16),
        child: Form(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
               // mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '내 고민 해결 방안 공유하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Container(
                  child: TextFormField(
                    readOnly: true,
                    initialValue: queryController.title.value,
                    decoration: InputDecoration(
                        labelText: 'Title',
                        helperText: '수정할 수 없는 필드입니다', // 도움말 텍스트 추가
                        suffixIcon:
                            Icon(Icons.lock, color: Colors.red), // 잠금 아이콘 추가
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        )),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  readOnly: true,
                  initialValue: '구현 X',
                  decoration: InputDecoration(
                      labelText: 'NickName',
                      helperText: '수정할 수 없는 필드입니다', // 도움말 텍스트 추가
                      suffixIcon:
                          Icon(Icons.lock, color: Colors.red), // 잠금 아이콘 추가
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      )),
                ),
                SizedBox(height: 8),
                TextFormField(
                  focusNode: focusNode,
                  maxLines: isExpanded ? null : 1,
                  readOnly: true,
                  initialValue: queryController.context.value,
                  decoration: InputDecoration(
                      labelText: 'Content',
                      helperText: '수정할 수 없는 필드입니다', // 도움말 텍스트 추가
                      suffixIcon:
                          Icon(Icons.lock, color: Colors.red), // 잠금 아이콘 추가
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      )),
                ),
                SizedBox(height: 8),
        
        
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Additional Content',
                      hintText: '추가적인 내용을 입력하세요.'),
        
                ),
                SizedBox(height: 16),
        
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Tags', hintText: '콤마로 구분됨, 공백 없는 태그를 입력하세요.'),
                ),
                SizedBox(height: 25),
        
                SizedBox(
                  width: 1000,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _submit,
        
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.all(10),
                    ),
                    child: Text('제출',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      
    );
  }
}