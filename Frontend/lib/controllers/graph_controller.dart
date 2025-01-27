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
        final tagGraphData = TagGraphData.fromJson(data);

        _tagList.value = Map<String, int>.from(tagGraphData.tagList);
        _tagGraph.value = List<List<String>>.from(tagGraphData.tagGraph.map((item) => List<String>.from(item)));

        print(tagList);
        print(tagGraph);
        isLoading.value = false;
        
      } else{
          print('Error: ${response.statusCode}');
          isLoading.value = false;
      }

  }
  
  Map<String, int> get tagList => Map<String, int>.from(_tagList);
  List<List<String>> get tagGraph => List<List<String>>.from(_tagGraph);
}
