import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';

class GraphController extends GetxController{
  
  //var psychiatryList = <Map<String, dynamic>>[].obs;
  
  var _tagList = <String, dynamic>{}.obs;      
  var _tagGraph = <List<String>>[].obs;
  
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
        final content = data['content'];
        final temp = json.decode(content);
        print(temp);
        //print(content);

        
      // Map<String,dynamic> data = json.decode(json.decode(response.body));
      
      //print(data);
      
      // var tagList = Map<String, int>.from(data['content']['_tagList']);
      //   print("Tag List: $tagList");
      
      // List<List<String>> tagGraph = List<List<String>>.from(
      //     data['content']['_tagGraph'].map((item) => List<String>.from(item)),
      //   );
      //   print("Tag Graph: $tagGraph");
        
        //final tagGraph = List<List<String>>.from(data["_tagGraph"].map((e) => List<String>.from(e)));



      // final content = decoded['content'];
      // _tagList.value = Map<String, int>.from(content['_tagList']);
      // _tagGraph.value = List<List<String>>.from(
      //   content['_tagGraph'].map((item) => List<String>.from(item)),
      // );
      
        // //print(data);
      
        
        // _tagList.value = Map<String, int>.from(data['content']['_tagList']);
        // _tagGraph.value = List<List<String>>.from(
        // data['content']['_tagGraph'].map((item) => List<String>.from(item))
        // );

       
        // print(_tagList.values);
        // _tagGraph.value = List<List<String>>.from(
        //   data['content']['_tagGraph'].map((item) => List<String>.from(item)),
        // );


        //print(_tagGraph.value);
        //_tagList.value = Map<String, dynamic>.from(data['content']['_tagList']);

        //print(_tagList.value);
        
        // _tagGraph.value = Map<String, String>.from(data['content']['_tagGraph']);

        // if(data is Map<String,dynamic> && data['content']['_tagGraph'] is List){
        
        
          
        //     _tagGraph.value = (data['content']['_tagGraph'] as List).map((e) => (e as List).cast<String>()).toList();
        //     //print('Title: ${post['title']} Tag : ${post['tag']}');
          
        // }
        // print(_tagGraph.value);
        
        
      } else{
          print('Error: ${response.statusCode}');
      }
        
      

    // } catch (error) {
    //   print('An error occurred: $error');
    // } finally{
      
    // }


   
  }
  
  
}