import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/curate/curate_controller.dart';
import 'package:to_doc_for_doc/src/curate/curate_detail_screen.dart';
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
      body: Obx( ()=>
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: screenHeight * 0.15,
                maxHeight: screenHeight * _mapHeight,
                child: Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Stack(children: [
                      Text('지도 영역',
                          style: TextStyle(fontSize: 20, color: Colors.grey[600])),

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
        final item = curateController.curateItems[index];
        return InkWell(
          onTap: () async {
            // print(item.id);
            await curateController.getCurateDetails(item.id);
            Get.to(() => CurateDetailScreen());
          },
          child: Card(
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
                      item.isRead ? Icons.mark_email_read : Icons.mail,
                      size: 16,
                      color: item.isRead ? Colors.green : Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      item.isRead ? '읽음' : '안읽음',
                      style: TextStyle(
                        color: item.isRead ? Colors.green : Colors.grey,
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
          ),
        );
            },
            childCount: curateController.curateItems.length,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}