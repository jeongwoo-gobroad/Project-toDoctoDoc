import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/query_controller.dart';
import 'package:to_doc/controllers/upload_controller.dart';
import 'package:to_doc/navigation_menu.dart';
import 'package:to_doc/screens/myPost.dart';
import 'package:to_doc/screens/myPost.dart';

class ResultEdit extends StatefulWidget {
  ResultEdit({super.key});

  @override
  State<ResultEdit> createState() => _ResultEditState();
}

class _ResultEditState extends State<ResultEdit> {
  QueryController queryController = Get.put(QueryController(dio: Dio()));
  final FocusNode focusNode = FocusNode();
  bool isExpanded = false;
  UploadController uploadController = Get.put(UploadController(dio:Dio()));

  bool isContentExpanded = false;

  final TextEditingController addController = TextEditingController(); //추후 수정
  final TextEditingController tagController = TextEditingController(); //추후 수정

  @override
  void dispose() {
    addController.dispose();
    tagController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  _submit() async {
    bool result = await uploadController.uploadResult(
      queryController.title.value,
      queryController.context.value,
      addController.text,
      tagController.text,
    );

    if (result) {
      Get.defaultDialog(
        title: '제출 완료',
        middleText: '게시판으로 이동하시겠습니까?',
        actions: [
          TextButton(
            onPressed: () {
              // 게시판으로 이동하고 이전화면으로 돌아갈 수 없게
              //Get.off(() => MypostTemp());
              Get.until((route) => route.isFirst);
              Get.to(() => MypostTemp());
            },
            child: Text('예'),
          ),
          TextButton(
            onPressed: () {
              // 아니오 버튼: 홈으로 이동
              Get.off(
                  () => NavigationMenu(startScreen : 0)); // Get.offAll은 모든 이전 화면을 제거하고 홈으로 이동
            },
            child: Text('아니오'),
          ),
        ],
        barrierDismissible: false,
      );
    } else {
      Get.snackbar(
        '오류',
        '제출에 실패했습니다. 다시 시도해주세요.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '내 고민 해결 방안 공유하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            //제목목
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '제목',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        queryController.title.value,
                        style: TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '수정할 수 없는 필드입니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            //내용
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      '내용',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        isContentExpanded = !isContentExpanded;
                      });
                    },
                    trailing: Icon(
                      isContentExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: isContentExpanded
                        ? Padding(
                            key: ValueKey(1),
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    queryController.context.value,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            key: ValueKey(2),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Text(
                                  queryController.context.value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            //내용용
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '추가 내용',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: addController,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: '추가적인 내용을 입력하세요.',
                        hintText: '추가적인 내용을 입력하세요.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            //태그
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '태그',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: tagController,
                      decoration: InputDecoration(
                        labelText: 'Tags',
                        hintText: '콤마(,)로 구분하여 태그 입력, 공백 없이 입력하세요.',
                        prefixIcon: Icon(Icons.tag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (text) {
                        // 태그입력 유효성 검사
                        if (text.contains(' ')) {
                          //공백포함 -> 제거거
                          //추가적으로 ,뒤에 아무것도 안치는것도 방지해야할듯 (추후)
                          Get.snackbar(
                            '태그 입력 오류',
                            '태그에 공백을 포함할 수 없습니다.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );

                          tagController.text = text.replaceAll(' ', '');
                          tagController.selection = TextSelection.fromPosition(
                            TextPosition(offset: tagController.text.length),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 8)
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: _submit, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16), 
                ),
                child: Text(
                  '제출',
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
    );
  }
}
