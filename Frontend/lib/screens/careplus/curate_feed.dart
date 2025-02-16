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
  final CurateListController curateListController = Get.put(CurateListController());
  late ScrollController _scrollController;
  int randomIndex = Random().nextInt(7);
  int sortOrder = -1; //최신순 기본
  int amount = 7; //초기 7개


  final Color themeColor = const Color.fromARGB(255, 225, 234, 205);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      curateListController.getCurateList(sortOrder, amount, "");
    });
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date).toLocal();
    return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
  }

  void _toggleSortOrder() {
    sortOrder = sortOrder == -1 ? 1 : -1;
    curateListController.curateList.clear();
    curateListController.getCurateList(sortOrder, amount, "");
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !curateListController.curateLoading.value) {
      String lastId = "";
      if (curateListController.curateList.isNotEmpty) {
        lastId = curateListController.curateList.last.id;
        print('lastId : $lastId');
      }
      curateListController.getCurateList(sortOrder, amount, lastId);
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

  Future<void> togglePublic(String curateId, bool newValue) async {
    if (newValue) {
      await curateListController.curateMakePublic(curateId);
    } else {
      await curateListController.curateMakePrivate(curateId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
  pinned: true,
  expandedHeight: MediaQuery.of(context).size.height /2,

  flexibleSpace: FlexibleSpaceBar(
    collapseMode: CollapseMode.pin,
    background: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          images[randomIndex],
          fit: BoxFit.cover,
        ),
        // 하단 그라데이션 및 정렬 버튼
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
                    sortOrder == -1 ? Icons.arrow_downward : Icons.arrow_upward,
                    color: Colors.white,
                  ),
                  label: Text(
                    sortOrder == -1 ? '최신 순' : '오래된 순',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black26,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: _toggleSortOrder,
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
                  final item = curateListController.curateList[index];
                  final commentCount = item.comments.length;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    elevation: 1.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${formatDate(item.date.toIso8601String())}에 신청한 큐레이팅',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.comment, size: 16),
                            SizedBox(width: 4),
                            Text('댓글 ${item.comments.length}개'),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.isPublic ? "공개" : "비공개",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: item.isPublic ? const Color.fromARGB(255, 180, 193, 152) : Colors.redAccent,
                            ),
                          ),
                          SizedBox(width: 8),
                          Switch(
                            activeColor: themeColor,
                            activeTrackColor: themeColor.withOpacity(0.6),
                            inactiveThumbColor: Colors.redAccent,
                            inactiveTrackColor: Colors.red[200],
                            value: item.isPublic,
                            onChanged: (newValue) {
                              togglePublic(item.id, newValue);
                            },
                          ),
                        ],
                      ),
                      onTap: () async{
                        await curateListController.getPost(item.id);
                        Get.to(() => CurationScreen(currentId: item.id));
                      },
                    ),
                  );
                },
                childCount: curateListController.curateList.length,
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Obx(
                () => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: curateListController.curateLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
