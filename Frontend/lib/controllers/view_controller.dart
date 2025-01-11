import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:to_doc/controllers/class/post.dart';

import '../auth/auth_dio.dart';

class ViewController extends GetxController{
  final Dio dio;

  RxString uid = "".obs;
  var feedData = {}.obs;
  var title = "".obs;
  var details = "".obs;
  RxString additional_material = "".obs;
  var createdAt = "".obs;
  RxString editedAt = "".obs;
  RxString tag = "".obs;
  var usernick = "".obs; 
  var currentId = "".obs;
  var isLoading = false.obs;
  RxList<Post> feed = <Post>[].obs;

  ViewController({required this.dio});

  Future<void> getFeed(String postId) async{
    dio.interceptors.add(CustomInterceptor());

    //로딩
    isLoading.value = true;
    currentId.value = postId;
    
    //final prefs = await SharedPreferences.getInstance();
    //final token = prefs.getString('jwt_token');

    /*
    if(token == null){
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
     */

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/view/$postId',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      )
    );

    /*
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/view/$postId'),
      headers: {
        'Content-Type':'application/json',
        'authorization':'Bearer $token',
      },
    );
     */


    if(response.statusCode == 200){
      final data = json.decode(response.data);
      print(data);
      final post = Post.fromJson(data['content']);
      feed.add(post);
      //print('Feed 추가 성공: ${feed}');

      uid.value = data['content']['userid'];
      title.value = data['content']['title'];
      details.value = data['content']['details'];
      additional_material.value = data['content']['additional_material'];
      createdAt.value = data['content']['createdAt'];
      editedAt.value = data['content']['editedAt'];
      tag.value = data['content']['tag'];
      usernick.value = data['content']['usernick'];
      
      print('제목: ${title.value} , 수정된 시각: $editedAt');
    }
    
    isLoading.value = false;
  }
}
