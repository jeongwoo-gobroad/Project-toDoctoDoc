import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';
import 'package:to_doc/controllers/map_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:to_doc/screens/careplus/curate_list.dart';

class CurateFeed extends StatefulWidget {
  @override
  _CurateFeedState createState() => _CurateFeedState();
}

class _CurateFeedState extends State<CurateFeed> {
  
  bool isLoading = true;
  late ScrollController _scrollController;
  final CurateListController curateListController = Get.put(CurateListController(dio:Dio()));
  double _mapHeight = 0.5;
  bool isradiusNotSelected = true;
  bool showMap = true;
  int randomIndex = 0;

  @override
  void initState() {
    super.initState();
    curateListController.getList();
    final random = Random();
    randomIndex = random.nextInt(images.length);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }
  String formatDate(String date){
    DateTime dateTime = DateTime.parse(date).toUtc().add(Duration(hours: 9));
    String formattedDate = DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);

    return formattedDate;


  }
  void _scrollListener() {
    
    final scrollOffset = _scrollController.offset;
    final maxScroll = MediaQuery.of(context).size.height * 0.3; //최대 스크롤

    setState(() {
      if (scrollOffset > maxScroll) {
        //showMap = false; // 지도 완전히 숨기기
      } else {
        //showMap = true;
        _mapHeight = 0.5 - (scrollOffset / (maxScroll * 2));
        _mapHeight = _mapHeight.clamp(0.15, 0.5);
      }
    });
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      //mapController.loadNextPage();
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      
        body: Obx(
              () => CustomScrollView(
                slivers: [
                  
                  SliverAppBar(
                    pinned: true,
                      expandedHeight: MediaQuery.of(context).size.height /2,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.asset(images[randomIndex], fit: BoxFit.cover),
                      ),
                  ),
                  SliverList(
                    
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final curateList = curateListController.CurateList[index];
                        
                        
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          elevation: 2.0, 
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side:  
                                BorderSide.none,
                          ),
                          child: ListTile(
                            
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${formatDate(curateList['date'])}에 신청한 큐레이팅',
                                    style: TextStyle(
                                      fontWeight: 
                                          FontWeight.bold
                                          ,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                              ],
                            ),
                           onTap: (){
                            //id
                            //print(curateList['_id']);
                            curateListController.getPost(curateList['_id']);


                            Get.to(()=> CurationScreen(currentId: curateList['_id']));}, 
                          ),
                        );
                      },
                      childCount: curateListController.CurateList.length,
                    ),
                  ),
                  // if (mapController.isLoading.value)
                  //   SliverToBoxAdapter(
                  //     child: Center(
                  //       child: CircularProgressIndicator(),
                  //     ),
                  //   ),
                ],
              ),
            ),
    );
  }
}


