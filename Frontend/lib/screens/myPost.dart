import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/myPost_controller.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/pageView.dart';

class MypostTemp extends StatefulWidget {
  MypostTemp({super.key});

  @override
  State<MypostTemp> createState() => _MypostTempState();
}

class _MypostTempState extends State<MypostTemp> {
  final ViewController viewController = Get.put(ViewController());
  final MypostController controller = Get.put(MypostController());
  final TextEditingController _tagController = TextEditingController();
  var searchResults = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    controller.fetchMyPost(); // 초기 게시물 가져오기
  }

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date);
      return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }

  Future<void> _searchByTag() async {
    searchResults.clear();
    String tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      controller.isLoading.value = true;
      searchResults.value = await controller.tagSearch(tag);
      controller.isLoading.value = false;
      print(searchResults);

      if(searchResults.isEmpty){
        _resetSearch();

      }
    }
  }

  void _resetSearch() {
    _tagController.clear();
    searchResults.clear(); // 검색 결과 초기화
  }
  Future<void> _onRefresh() async{
    await controller.fetchMyPost();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '내 게시물',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: '태그를 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchByTag,
                  child: Text('검색'),
                ),
                
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

             
              final postsToShow = searchResults.isNotEmpty //검색결과가 있으면 searchResult을 표시, 없으면 전체 post표시
                  ? searchResults
                  : controller.posts;

              if (postsToShow.isEmpty) {
                return Center(
                  child: Text('게시물이 없습니다.'),
                );
              }

              return NotificationListener<ScrollNotification>(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  
                    child: ListView.builder(
                      itemCount: postsToShow.length,
                      itemBuilder: (context, index) {
                        final post = postsToShow[index];
                        return ListTile(
                          onTap: () async {
                            await viewController.getFeed(post['_id']);
                            Get.to(() => Pageview());
                          },
                          title: Text(
                            post['title'] ?? '제목 없음',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (post['tag'] != null && post['tag'].isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '태그: ${post['tag']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                SizedBox(height: 4),
                                Text(
                                  '작성일: ${formatDate(post['createdAt'] ?? '')}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
