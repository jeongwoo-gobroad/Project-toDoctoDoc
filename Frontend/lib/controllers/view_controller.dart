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

  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();


  Future<void> getFeed(String postId) async{
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    isLoading.value = true;
    currentId.value = postId;

    final response = await dio.get(
      '${Apis.baseUrl}mapp/view/$postId',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      )
    );

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
