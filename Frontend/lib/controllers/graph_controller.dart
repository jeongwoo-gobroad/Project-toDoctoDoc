import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/class/graph_model.dart';

import '../auth/auth_dio.dart';
import 'package:dio/dio.dart';

class TagGraphController extends GetxController{
  final Dio dio;
  RxBool isLoading = false.obs;
  //var psychiatryList = <Map<String, dynamic>>[].obs;
  
  var _tagList = <String, int>{}.obs;      
  var _tagGraph = <List<String>>[].obs;
  var tagPositions = <String, Offset>{}.obs;


  final _tagInfoMap = <String, TagInfo>{}.obs;

  TagGraphController({required this.dio});

  Future<void> getGraph() async{
    isLoading.value = true;
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/graphBoard',
      options: Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      )
    );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.data);
        print(data);
        final tagGraphData = GraphBoardData.fromJson(data);
        _tagInfoMap.value = tagGraphData.content.bubbleList;
      
        print('Loaded tags: ${_tagInfoMap.length}');
        print('Tag data: $_tagInfoMap');
        
        isLoading.value = false;
        
        //임시시
        // final tagInfo = _tagInfoMap['지각'];
        // if (tagInfo != null) {

        // print('태그 카운트: ${tagInfo.tagCount}');
        // print('조회수: ${tagInfo.viewCount}');
      
      } else{
          print('Error: ${response.statusCode}');
          isLoading.value = false;
      }

  }
  
  Map<String, TagInfo> get tags => Map.from(_tagInfoMap);
}
