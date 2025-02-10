import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:to_doc/screens/careplus/curate_screen.dart';

class CurateFeed extends StatefulWidget {
  @override
  _CurateFeedState createState() => _CurateFeedState();
}

class _CurateFeedState extends State<CurateFeed> {
  bool isLoading = true;
  late ScrollController _scrollController;
  final CurateListController curateListController = Get.put(CurateListController());
  double _mapHeight = 0.5;
  bool isradiusNotSelected = true;
  bool showMap = true;
  int randomIndex = Random().nextInt(7);
  bool isAscending = false;

  @override
  void initState() {
    // 버그가 있어서 초기화 할때 생성 (숫자를 하드 코딩 했는데 이건 수정 바람)
    // final random = Random();
    // randomIndex = random.nextInt(images.length);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      curateListController.getList();
      //isAscending = false;
      //_sortList(false);
      _scrollController = ScrollController();
      _scrollController.addListener(_scrollListener);
    });
  }

  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date).toLocal();
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    return formattedDate;
  }

  void _sortList([bool toggle = true]) {
    setState(() {
    if (toggle) {
      isAscending = !isAscending;
    }
    curateListController.CurateList.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
  });
  }

  void _scrollListener() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = MediaQuery.of(context).size.height * 0.3;

    setState(() {
      _mapHeight = 0.5 - (scrollOffset / (maxScroll * 2));
      _mapHeight = _mapHeight.clamp(0.15, 0.5);
    });
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
    }
  }

  final List<String> images = [
    'asset/images/image1.jpg',
    'asset/images/image2.jpg',
    'asset/images/image3.jpg',
    'asset/images/image4.jpg',
    'asset/images/image5.jpg',
    'asset/images/image6.jpg',
    'asset/images/image7.jpg',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: MediaQuery.of(context).size.height /2,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // 배경 이미지
                    Image.asset(
                      images[randomIndex],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    // 하단 그라데이션 및 버튼
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: Icon(
                                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                color: Colors.white,
                              ),
                              label: Text(
                                isAscending ? '오래된 순' : '최신 순',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black26,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: _sortList,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final curateList = curateListController.CurateList[index];
                  final commentCount = curateList['comments']?.length ?? 0;
                  
                  return Card(
                    margin: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    elevation: 2.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide.none,
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${formatDate(curateList['date'])}에 신청한 큐레이팅',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.comment, size: 16),
                              SizedBox(width: 4),
                              Text('댓글 $commentCount개'),
                            ],
                          ),
                        ],
                      ),
                      onTap: (){
                        curateListController.getPost(curateList['_id']);
                        Get.to(()=> CurationScreen(currentId: curateList['_id']));
                      },
                    ),
                  );
                },
                childCount: curateListController.CurateList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}