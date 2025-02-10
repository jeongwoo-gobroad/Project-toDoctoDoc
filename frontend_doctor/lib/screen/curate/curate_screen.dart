import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/curate/curate_controller.dart';
import 'package:to_doc_for_doc/screen/curate/curate_detail_screen.dart';
import 'package:intl/intl.dart';

class CurateScreen extends StatefulWidget {
  @override
  _CurateScreenState createState() => _CurateScreenState();
}

class _CurateScreenState extends State<CurateScreen> {
  late ScrollController _scrollController;
  double _mapHeight = 0.5;
  bool showMap = true;
  CurateController curateController = Get.put(CurateController());

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toUtc().add(Duration(hours: 9));
      return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }

  @override
  void initState() {
    curateController.getCurateInfo('5');
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = MediaQuery.of(context).size.height * 0.3;

    setState(() {
      if (scrollOffset > maxScroll) {
        showMap = false;
      } else {
        showMap = true;
        _mapHeight = 0.5 - (scrollOffset / (maxScroll * 2));
        _mapHeight = _mapHeight.clamp(0.15, 0.5);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('큐레이팅 요청 목록',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: Obx(
        () => CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        curateController.filterStatus.value = 'unread';
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('안읽음만 보기',
                          style: TextStyle(color: curateController.filterStatus.value == 'unread' ? Colors.blue : Colors.black87, fontSize: 14)),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        curateController.filterStatus.value = 'read';
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('읽음만 보기',
                          style: TextStyle(
                              color:
                                  curateController.filterStatus.value == 'read'
                                      ? Colors.blue
                                      : Colors.black87,
                              fontSize: 14)),
                    ),
                    Spacer(),
                    DropdownButton<String>(
                      value: curateController.sortOrder.value == 'desc'
                          ? '최신순'
                          : '오래된순',
                      items: [
                        DropdownMenuItem(value: '최신순', child: Text('최신순')),
                        DropdownMenuItem(value: '오래된순', child: Text('오래된순')),
                      ],
                      onChanged: (value) {
                        if (value == '최신순') {
                          curateController.sortOrder.value = 'desc';
                        } else {
                          curateController.sortOrder.value = 'asc';
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: screenHeight * 0.15,
                maxHeight: screenHeight * _mapHeight,
                child: Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Stack(
                      children: [
                        Text('지도 영역',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey[600])),

                        //build radius 선택기 추후후
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = curateController.sortedAndFilteredItems[index];
                  return InkWell(
                    onTap: () async {
                      // print(item.id);
                      await curateController.getCurateDetails(item.id);
                      Get.to(() => CurateDetailScreen(userName: item.users.map((user) => user.userNick).join(", ")));
                    },
                    child:
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15 , vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.users.map((user) => user.userNick).join(", ")}님의 큐레이팅 요청',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                formatDate(item.date),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),

                              Row(
                                children: [
                                  Icon(
                                    item.isRead
                                        ? Icons.mark_email_read
                                        : Icons.mail,
                                    size: 16,
                                    color: item.isRead ? Colors.green : Colors.grey,
                                  ),
                                  SizedBox(width: 8),

                                  Text(
                                    item.isRead ? '읽음' : '안읽음',
                                    style: TextStyle(
                                      color:
                                      item.isRead ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.comment, size: 15,),
                              SizedBox(width: 5,),
                              Text(
                                '${item.comments.length}',
                                style: TextStyle(
                                  fontSize: 15,
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    /*Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        leading: Icon(
                          Icons.medical_services,
                          color: Colors.blue,
                          size: 30,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.users.map((user) => user.userNick).join(", ")}님의 큐레이팅 요청',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    formatDate(item.date),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                item.isRead
                                    ? Icons.mark_email_read
                                    : Icons.mail,
                                size: 16,
                                color: item.isRead ? Colors.green : Colors.grey,
                              ),
                              SizedBox(width: 8),
                              
                             Text(
                                  item.isRead ? '읽음' : '안읽음',
                                  style: TextStyle(
                                    color:
                                        item.isRead ? Colors.green : Colors.grey,
                                  ),
                                ),
                              
                            ],
                          ),
                        ),
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '상세정보를 보려면 누르세요',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '댓글: ${item.comments.length}개',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),*/
                  );
                },
                childCount: curateController.sortedAndFilteredItems.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
