import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ViewController extends GetxController{
  var feedData = {}.obs;
  var title = "".obs;
  var details = "".obs;
  var additional_material = "".obs;
  var createdAt = "".obs;
  var editedAt = "".obs;
  var tag = "".obs;
  var usernick = "".obs; 
  var currentId = "".obs;
  var isLoading = false.obs;

  Future<void> getFeed(String postId) async{

    //로딩
    isLoading.value = true;
    currentId.value = postId;
    //토큰? Access Token으로 접근하고 1회 실패하면 Refresh Token으로 접근하면 되고, Refresh Token으로 접근하면 헤더에 Access_Token에 Access Token을 담고 Refresh_token에 Refresh Token을 담아서 줌. 
    /* if token == null -> 로그인이 필요합니다. */

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if(token == null){

      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }


    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/view/$postId'),
      headers: {
        'Content-Type':'application/json',
        'authorization':'Bearer $token',
      },
      

    );

    if(response.statusCode == 200){
      final data = json.decode(json.decode(response.body));
      
      title.value = data['content']['title'];
      details.value = data['content']['details'];
      additional_material.value = data['content']['additional_material'];
      createdAt.value = data['content']['createdAt'];
      editedAt.value = data['content']['editedAt'];
      tag.value = data['content']['tag'];
      usernick.value = data['content']['usernick'];
      
    }
    
    isLoading.value = false;
    
  }





}
