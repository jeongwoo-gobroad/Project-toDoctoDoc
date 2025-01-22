import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/myPost_controller.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/pageView.dart';

class TagList extends StatefulWidget {
  final String tag;
  const TagList({required this.tag, super.key});

  @override
  State<TagList> createState() => _TagListState();
}

class _TagListState extends State<TagList> {
  MypostController mypostController = Get.put(MypostController(dio: Dio()));
  var searchResults = <Map<String, dynamic>>[].obs;
  ViewController viewController = Get.find<ViewController>();

  @override
  void initState() {
    _searchByTag();
    super.initState();
  }
  Future<void> _searchByTag() async {
    searchResults.clear();
    searchResults.value = await mypostController.tagSearch(widget.tag);
    print(searchResults);
    if(searchResults.isEmpty){
      _resetSearch();
      Get.snackbar('Error', '검색 결과가 없습니다.');
    }
  }
  Future<void> _onRefresh() async {
    await _searchByTag();
  }
  void _resetSearch() {
   
    searchResults.clear(); // 검색 결과 초기화
  }
   String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toLocal();
      return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.tag}', style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (mypostController.isTagLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: searchResults.isEmpty
              ? Center(
                  child: Text('검색 결과가 없습니다.'),
                )
              : ListView.separated(
                  itemCount: searchResults.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final post = searchResults[index];
                    return ListTile(
                      onTap: () async {
                        //print(post['_id']);
                        await viewController.getFeed(post['_id']);
                        Get.to(() => Pageview());
                      },
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post['tag'] != null && post['tag'].isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                //vertical: 4,
                                //horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                //color: Colors.blue[50],
                                //borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '#${post['tag']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          Text(
                            post['title'] ?? '제목 없음',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${post['details']}',
                              overflow: TextOverflow.ellipsis,
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
        );
      }),
    );
  }
}