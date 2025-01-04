import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/query_controller.dart';

class ResultEdit extends StatefulWidget {
  ResultEdit({super.key});

  @override
  State<ResultEdit> createState() => _ResultEditState();
}

class _ResultEditState extends State<ResultEdit> {
  QueryController queryController = Get.put(QueryController());
  final FocusNode focusNode = FocusNode();
  bool isExpanded = false;
   @override
  void initState() {
    super.initState();
    focusNode.addListener(() { //focus상태감지
      setState(() {
        isExpanded = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('공유하기')),
      body: SingleChildScrollView(
        //padding: EdgeInsets.all(16),
        child: Form(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width - 32,
            height: isExpanded ? 200 : 60, //expand상태면 200
            padding: EdgeInsets.all(8),
        
        
          
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
        
        
                Container(
                  width: 1000,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      
                
                        
                    },
        
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
      ),
    );
  }
}