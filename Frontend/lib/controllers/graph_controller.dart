import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/class/graph_model.dart';

class TagGraphController extends GetxController{
  
  //var psychiatryList = <Map<String, dynamic>>[].obs;
  
  var _tagList = <String, int>{}.obs;      
  var _tagGraph = <List<String>>[].obs;
  var tagPositions = <String, Offset>{}.obs; 
  Future<void> getGraph() async{
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if(token == null){

      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    // try {
      //isLoading.value = true;
      final response = await http.get(
        Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/graphBoard'),
        headers: {
          'Content-Type':'application/json',
          'Authorization': 'Bearer $token', 
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(json.decode(response.body));
        final tagGraphData = TagGraphData.fromJson(data);
        
        // print(tagGraphData.tagList);
        // print(tagGraphData.tagGraph);
        //print(content);
        _tagList.value = Map<String, int>.from(tagGraphData.tagList);
        _tagGraph.value = List<List<String>>.from(tagGraphData.tagGraph.map((item) => List<String>.from(item)));

        print(tagList);
        print(tagGraph);

        
      } else{
          print('Error: ${response.statusCode}');
      }

  }
  
  Map<String, int> get tagList => Map<String, int>.from(_tagList);
  List<List<String>> get tagGraph => List<List<String>>.from(_tagGraph);
}
