import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';


class CurationScreen extends StatefulWidget {
  @override
  _CurationScreenState createState() => _CurationScreenState();
}

class _CurationScreenState extends State<CurationScreen> {
  bool isPostExpanded = false;
  bool isAIExpanded = false;
  final CurateListController curateListController = Get.put(CurateListController());

  void togglePostExpansion() {
    setState(() {
      isPostExpanded = !isPostExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("큐레이팅 화면"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 포스트 드롭다운
              
                 GestureDetector(
                  onTap: () {
                    if (curateListController.posts.isNotEmpty) {
                    togglePostExpansion();
                  }
                  },
                  child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "포스트",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        isPostExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.purple[900],
                      ),
                    ],
                  ),
                ),
              ),
              
              

              if (isPostExpanded && curateListController.posts.isNotEmpty)
                Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Column(

                      children: curateListController.posts.map((post) {
                        return Card(
                          margin: const EdgeInsets.only(top: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: InkWell(
                          onTap: () {
                            print("${post['title']} 클릭됨");


                          },
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                            margin: const EdgeInsets.only(top: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(post['title'] ?? "제목 없음"),
                          ),
                          ),
                        );
                      }).toList(),
                    )),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
