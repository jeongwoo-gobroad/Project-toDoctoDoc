import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:to_doc_for_doc/controllers/curate/curate_detail_model.dart';
import 'content_model.dart';

class CurateController extends GetxController {
  Rx<CurateDetail?> curateDetail = Rx<CurateDetail?>(null);
  var isLoading = true.obs;
  RxBool isPremium = false.obs;
  var CurateList = <Map<String, dynamic>>[].obs;
  var chatList = <Map<String, dynamic>>[].obs;
  var comments = <Map<String, dynamic>>[].obs;
  //var posts  
  var posts = <Map<String, dynamic>>[].obs;
  
  var curateItems = <ContentItem>[].obs;

  Future<bool> getCurateInfo(String radius) async{
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if(token == null){

      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return false;
    }

    try {
      
      final response = await http.get(
        Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/curate?radius=$radius'),
        headers: {
          'Content-Type':'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(json.decode(response.body));
        print(data);
        final contentResponse = ContentResponse.fromJson(data);
        curateItems.value = contentResponse.content;

        //print(curateItems);
        

        // if(data is Map<String,dynamic> && data['content']['list'] is List){
        // List<dynamic> contentList = data['content']['list'];
        return true;

      } else {

        return false;
      }

    } catch (error) {
      print('An error occurred: $error');
      return false;
    } 
    


  }

  Future<void> addComment(String id, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    // try {
    //isLoading.value = true;
    final response = await http.post(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/curate/comment/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
          'comment': comment,
      }),
    );

    if (response.statusCode == 200) {
      Get.snackbar('Success', '댓글을 남겼습니다.');
      await getCurateDetails(id);
      await getCurateInfo('5'); //추후에 5가아닌 radius인자로로
      refresh();
    }
    else{
      Get.snackbar('Failed', '댓글을 남기지 못했습니다.');
    }
  }
  Future<void> commentModify(String comment_id, String detail_id, String updatedComment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    /* 추후 댓글 doctor 속성과 doctorinfo에서 받아오는 id가 같은지를 확인 구현현 */
    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    // try {
    //isLoading.value = true;
    final response = await http.patch(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/curate/commentModify/$comment_id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
          'comment': updatedComment,
      }),
    );

    if (response.statusCode == 200) {
      Get.snackbar('Success', '댓글이 수정되었습니다.');
      await getCurateDetails(detail_id);
      
      refresh();
    }
    else if(response.statusCode == 401) {
      Get.snackbar('Failed', '본인의 댓글이 아닙니다.');
    }
    else if(response.statusCode == 403){
      Get.snackbar('Failed', '에러 발생');
    }
  }
  Future<void> commentDelete(String comment_id, String detail_id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    /* 추후 댓글 doctor 속성과 doctorinfo에서 받아오는 id가 같은지를 확인 구현현 */
    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    // try {
    //isLoading.value = true;
    final response = await http.delete(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/curate/commentModify/$comment_id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      
    );
    //마찬가지로 내 댓글임을 확인하는 로직 구현할것


    if (response.statusCode == 200) {
      Get.snackbar('Success', '댓글이 삭제되었습니다.');
      await getCurateDetails(detail_id);
      await getCurateInfo('5'); //추후에 5가아닌 radius인자로
      refresh();
    }
    else if(response.statusCode == 401) {
      Get.snackbar('Failed', '본인의 댓글이 아닙니다.');
    }
    else if(response.statusCode == 403){
      Get.snackbar('Failed', '에러 발생');
    }
  }

  Future<void> getCurateDetails(String id) async {
    
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    // try {
    //isLoading.value = true;
    isLoading(true);
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/curate/details/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(json.decode(response.body));
      print(data);
      final curateResponse = CurateDetailResponse.fromJson(data);
      curateDetail.value = curateResponse.content;

      //print(curateDetail[]);
    

      
     
    }
    isLoading(false);
  }
  
  
}
