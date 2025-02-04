import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:to_doc/controllers/hospital/hospital_information_controller.dart';
import 'package:to_doc/controllers/map_controller.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/navigator/side_menu.dart';
import 'package:to_doc/screens/hospital/star_rating_editor.dart';

import 'hospital_detail_view.dart';

//import 'package:to_doc/map/marker.dart';

class MapAndListScreen extends StatefulWidget {
  @override
  _MapAndListScreenState createState() => _MapAndListScreenState();
}

class _MapAndListScreenState extends State<MapAndListScreen> {
  //List<dynamic> hospitalList = [];
  bool isLoading = true;

  late ScrollController _scrollController;
  final MapController mapController = Get.put(MapController(dio: Dio()));
  UserinfoController userinfoController = Get.find<UserinfoController>();
  HospitalInformationController hospitalInformationController = HospitalInformationController();
  late KakaoMapController kakaoMapController; //카카오 맵 컨트롤러러

  double _mapHeight = 0.5; //지도 비율율
  bool isradiusNotSelected = true;
  bool showMap = true;
  bool isDropdownOpen = false;

  List<CustomOverlay> customOverlays = [];
  //Set<Marker> markers = {}; //마커들 set
  bool isSortByStars = false;
  bool showPremiumOnly = false;

  @override
  void initState() {
    mapController.getMapInfo('1');
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    // final customOverlay = CustomOverlay(
    //   customOverlayId: UniqueKey().toString(),
    //   latLng: LatLng(userinfoController.latitude.value, 126.570667),
    //   content:
    //       '<p style="background-color: white; padding: 8px; border-radius: 8px;">내 지역</p>',
    //   xAnchor: 1,
    //   yAnchor: -1,
    //   zIndex: 5,
    // );

    //customOverlays.add(customOverlay);

    super.initState();
  }

  openHospitalDetailView(BuildContext context, Map<String, dynamic> hospital) {
    showModalBottomSheet(
      //shape : ,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      elevation: 0,
      builder: (context) {//(BuildContext context) => HospitalDetailView(),
        return DraggableScrollableSheet(
          expand: false,
          snap: true,
          snapSizes: [0.2, 1.0],
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(height: 2000, child: HospitalDetailView(hospital: hospital))
            );
          }
        );
      },
    );
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

  void _toggleSortByStars() {
    setState(() {
      isSortByStars = !isSortByStars;
      if (isSortByStars) {
        mapController.psychiatryList.sort((a, b) {
          int starsA = a['stars'] ?? 0;
          int starsB = b['stars'] ?? 0;
          return starsB.compareTo(starsA);
        });
      } else {
        //거리순 다시 정렬 
        mapController.psychiatryList.sort((a, b) {
          int distanceA = int.parse(a['distance'].toString());
          int distanceB = int.parse(b['distance'].toString());
          return distanceA.compareTo(distanceB);
        });
      }
    });
  }

  void _togglePremiumOnly() { //프리미엄만 보여주기기
    setState(() {
      showPremiumOnly = !showPremiumOnly;
      if (showPremiumOnly) {
        mapController.psychiatryList.removeWhere((hospital) => 
          !(hospital['isPremiumPsychiatry'] ?? false));
      } else {
        mapController.getMapInfo(mapController.currentRadius);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: Obx(() => SideMenu(
          userinfoController.usernick.value,
          userinfoController.email.value
        )),
      appBar: AppBar(
        title: Text('근처 마음병원 찾기',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
        ),
      ),
      body: Obx(
        () => CustomScrollView(
          slivers: [
            // 상단지도영역
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: screenHeight * 0.15,
                maxHeight: screenHeight * _mapHeight,
                child: Stack(children: [
                  Obx( ()=>
                    KakaoMap(
                      onMapCreated: (controller) async {
                        kakaoMapController = controller;
                        mapController.markers.add(Marker(
                        markerId: 'myLocationMarker',
                      
                        latLng: LatLng(userinfoController.latitude.value,
                          userinfoController.longitude.value),
                        width: 50,
                        height: 45,
                    
                      ));
                          // for(var item in mapController.psychiatryList) { //순회하면서 marker add
                          //   if(item is Map<String, dynamic> && item.containsKey('x') && item.containsKey('y')) {
                          //     setState(() {
                          //       print('main임 ${item['x']}');
                          //       print(item['y']);
                          //       if(item['x'] is double){print('double인데요');}
                          //       double longitude = double.parse(item['x']);
                          //       //if(latitude is double){print('이제야 double인데요');}
                          //       double latitude = double.parse(item['y']);

                          //       String markerId = 'marker_${item['place_name']}';
                          //       //print(markerId);
                          //       if(item['isPremiumPsychiatry'] != true){
                                  
                          //         markers.add(Marker(
                          //           markerId: markerId, 
                          //           latLng: LatLng(latitude, longitude),
                          //           width: 50,
                          //           height: 45,
                          //           )
                          //         );

                          //       }else{
                          //         print('premium이네요');
                          //         markers.add(Marker(
                          //             markerId: markerId,
                          //             latLng: LatLng(latitude, longitude),
                          //             width: 24,
                          //             height: 35,
                          //             markerImageSrc:
                          //             'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png',
                          //             zIndex: 4,
                          //       ));
                          //       }
                                
                          //     });
                              
                          //   }
                          // }
                        //print('marker: $markers');
                      },
                      markers: mapController.markers.toList(),
                      //customOverlays: customOverlays,
                      center: LatLng(userinfoController.latitude.value,
                          userinfoController.longitude.value),
                      // markers.add(Marker(markerId: markerId))
                      // onMapTap: (LatLng(123,123)) {
                      // debugPrint('***** [DEBUG] ${latLng.toString()}');
                      // },
                    ),
                  ),

                  _buildRadiusSelector(),
                ]),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final hospital = mapController.psychiatryList[index];
                  final isPremium = hospital['isPremiumPsychiatry'];
                  final hasInfo = hospital['hasInfo'];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: (isPremium) ? BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.amber, width: 2)
                    ) : null,
                      child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                          ),
                          onPressed: () async {
                            // TODO 웹 용 주석 처리 ; 앱에선 주석 해제 요망


                            kakaoMapController.setCenter(LatLng(
                              double.parse(hospital['y']),
                              double.parse(hospital['x'])));

                            print('test');
                            if (hasInfo) {
                              if (await hospitalInformationController.getHospitalInformation(hospital['pid'])) {
                                openHospitalDetailView(context,
                                    hospitalInformationController.hospital);
                              }
                            }
                          },

                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        hospital['place_name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: (isPremium)? Colors.amber : Colors.black,
                                        ),
                                      ),
                                    ),

                                    Text('${hospital['distance']} m',
                                      style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold,),
                                    ),
                                    SizedBox(width: 5,),
                                    if (isPremium) Icon(Icons.verified, color: Colors.amber,),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (hospital['phone'] != null) ...[
                                      InkWell(
                                        onTap: () {

                                        },
                                        child: SizedBox(
                                          width: 130,
                                          child: Row(
                                            children: [
                                              Icon(Icons.phone_android, color: Colors.black,),
                                              Text(' ${hospital['phone']}', style: TextStyle(color: Colors.blue),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (hospital['address_name'] != null) ... [
                                      Text(' ${hospital['address_name']} ',
                                        style: TextStyle(color: Colors.black), overflow: TextOverflow.ellipsis,),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 5,),
                                if (hasInfo == false) Text('상세정보가 없습니다', style: TextStyle(color: Colors.grey),)
                                else ... [
                                  (hospital['stars'] == null)
                                    ? Text('별점이 없습니다')
                                    : StarRating(
                                        rating: (hospital['stars'].toDouble()),
                                        starSize: 20,
                                        isControllable: false,
                                        onRatingChanged: (rating) => {},
                                    ),
                                ],
                              ],
                            ),
                          /*onExpansionChanged: (isExpanded) {
                            if(isExpanded){
                            kakaoMapController.setCenter(LatLng(
                                double.parse(hospital['y']),
                                double.parse(hospital['x'])));
                            }
                          },
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
                                        color: Colors.grey[600], fontSize: 12.0),
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
                              child: Text(
                                '전화번호: ${hospital['phone']}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),*/
                      ),
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

  Widget _buildRadiusSelector() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 별점정렬 
              Container(
                margin: EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: _toggleSortByStars,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSortByStars ? Colors.amber : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: isSortByStars ? Colors.white : Colors.amber,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '후기순',
                          style: TextStyle(
                            color: isSortByStars ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 프리미엄필터터
              Container(
                margin: EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: _togglePremiumOnly,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: showPremiumOnly ? Colors.amber : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: showPremiumOnly ? Colors.white : Colors.amber,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '프리미엄',
                          style: TextStyle(
                            color: showPremiumOnly ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isDropdownOpen = !isDropdownOpen;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${mapController.currentRadius}km',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isDropdownOpen)
            Container(
              margin: EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(5, (index) {
                  final radius = (index + 1).toString();
                  return InkWell(
                    onTap: () {
                      RadiusSelect(radius);
                      setState(() {
                        isDropdownOpen = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index != 4 ? Colors.grey.shade200 : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        '$radius km',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
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
