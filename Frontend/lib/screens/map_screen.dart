import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:to_doc/controllers/map_controller.dart';
import 'package:get/get.dart';

class MapAndListScreen extends StatefulWidget {
  @override
  _MapAndListScreenState createState() => _MapAndListScreenState();
}

class _MapAndListScreenState extends State<MapAndListScreen> {
  //List<dynamic> hospitalList = [];
  bool isLoading = true;
  late ScrollController _scrollController;
  final MapController mapController = Get.put(MapController());
  double _mapHeight = 0.5; //지도 비율율
  bool isradiusNotSelected = true;
  bool showMap = true;

  @override
  void initState() {
    super.initState();
    
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    //스크롤 위치에 따라 지도높이조절
    final scrollOffset = _scrollController.offset;
    final maxScroll = MediaQuery.of(context).size.height * 0.3; //최대 스크롤

    setState(() {
      if (scrollOffset > maxScroll) {
        showMap = false; // 지도 완전히 숨기기
      } else {
        showMap = true;
        _mapHeight = 0.5 - (scrollOffset / (maxScroll * 2));
        _mapHeight = _mapHeight.clamp(0.15, 0.5);
      }
    });
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      mapController.loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void RadiusSelect(String radius) {
    setState(() {
      mapController.currentRadius = radius;
      mapController.currentPage = 1;
      mapController.getMapInfo(radius);
      isradiusNotSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: PopupMenuButton<String>(
          onSelected: RadiusSelect,
          itemBuilder: (BuildContext context) {
            return {'1', '2', '3', '4', '5'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text('반경 $choice km'),
              );
            }).toList();
          },
          child: Text('근처 마음병원 찾기',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
      ),
      body: isradiusNotSelected
          ? Center(child: Text('반경을 선택해주세요.'))
          : Obx(
              () => CustomScrollView(
                slivers: [
                  // 상단지도영역
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      minHeight: screenHeight * 0.15,
                      maxHeight: screenHeight * _mapHeight,
                      child: Container(
                        color: Colors.blueAccent,
                        alignment: Alignment.center,
                        child: Text(
                          '지도 부분',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final hospital = mapController.psychiatryList[index];
                        final isPremium = hospital['isPremiumPsychiatry'];

                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          elevation: isPremium ? 8.0 : 2.0, //프리미엄 항목 그림자 강조조
                          color: isPremium ? Colors.yellow[100] : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: isPremium
                                ? BorderSide(
                                    color: Colors.amber,
                                    width: 2.0) //프리미엄만 테두리처리리
                                : BorderSide.none,
                          ),
                          child: ExpansionTile(
                            leading: isPremium
                                ? Icon(Icons.local_hospital,
                                    color: Colors.amber, size: 30)
                                : Icon(Icons.local_hospital,
                                    color: Colors.blueAccent),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    hospital['place_name'],
                                    style: TextStyle(
                                      fontWeight: isPremium
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                                if (isPremium)
                                  Container(
                                    margin: EdgeInsets.only(left: 8.0),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Text(
                                      '광고',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(hospital['address_name'] ?? '주소 없음'),
                                if (isPremium)
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < (hospital['star'] ?? 0)
                                            ? Icons.star_border
                                            : Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                if (isPremium)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      '이 병원은 광고 서비스에 등록되어 있습니다.',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12.0),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Text(
                              '${hospital['distance']} m',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: 
                                Text(
                                  '전화번호: ${hospital['phone']}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: mapController.psychiatryList.length,
                    ),
                  ),
                  if (mapController.isLoading.value)
                    SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
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
