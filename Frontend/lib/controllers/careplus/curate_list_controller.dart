import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';

class CurateListController extends GetxController {

  RxBool isPremium = false.obs;
  var CurateList = <Map<String, dynamic>>[].obs;
  var chatList = <Map<String, dynamic>>[].obs;
  var comments = <Map<String, dynamic>>[].obs;
  //var posts  
  var posts = <Map<String, dynamic>>[].obs;
  UserinfoController userinfoController = Get.put(UserinfoController());
  
  // if(userinfoController.isPremium == 'true'){
  //   isPremium.value = true;
  //   print('premium account');
  // }
  // else{
  //   print('non-premium account');
  // }
  


  Future<void> getList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    // try {
    //isLoading.value = true;
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/list'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(json.decode(response.body));
      print(data);
      final ids = (data['content'] as List).map((item) => item['_id']).toList();
      print(ids); // _id 값 리스트 출력
      /*{error: false, result: careplus/list, content: [{_id: 677d595269eb1515eb40c500, comments: [], date: 2025-01-07T13:06:56.389Z}, {_id: 677d5b4169eb1515eb40c5a5, comments: [], date: 2025-01-07T13:06:56.389Z}, {_id: 677d5fa169eb1515eb40c6bb, comments: [], date: 2025-01-07T13:06:56.389Z}]}
[677d595269eb1515eb40c500, 677d5b4169eb1515eb40c5a5, 677d5fa169eb1515eb40c6bb]
[{_id: 677d595269eb1515eb40c500, comments: [], date: 2025-01-07T13:06:56.389Z}, {_id: 677d5b4169eb1515eb40c5a5, comments: [], date: 2025-01-07T13:06:56.389Z}, {_id: 677d5fa169eb1515eb40c6bb, comments: [], date: 2025-01-07T13:06:56.389Z}] */




       if(data['content'] is List){
        List<dynamic> contentList = data['content'];
        //데이터
        for(var post in contentList){
          CurateList.value = (data['content'] as List).map((e) => e as Map<String,dynamic>).toList();
          //print('Title: ${post['title']} Tag : ${post['tag']}');
        }
        print(CurateList.value);
      }
      //print(content);
    }
  }

  Future<void> getPost(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    // try {
    //isLoading.value = true;
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/post/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(json.decode(response.body));
      //print(data);
      //final posts = data['content']['posts'] as List;
      if (data['content'] != null && data['content']['posts'] is List) {
        posts.value = (data['content']['posts'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
      if (data['content'] != null && data['content']['ai_chats'] is List) {
        chatList.value = (data['content']['ai_chats'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
      print(chatList);
      //print(posts);

      //print(content);
    }
  
  }

  Future<void> requestCurate() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }
    if(userinfoController.isPremium.value == false){
      Get.snackbar('Error', '프리미엄 계정이 아닙니다.');
      return;
    }

    final response = await http.post(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/curate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(json.decode(response.body));
      print(data);
      

      //print(content);
    }


  }
}
/*혹시 어떤 부분이 특히 걱정이 되시는지 말씀해 주시면, 더 구체적으로 도와드릴 수 있을 것 같습니다. 긍정적인 마음으로 하루하루를 지나가다 보면, 분명 좋은 변화가 있을 거예요. 당신은 잘하고 계시니, 자신을 믿어보세요!, additional_material: , createdAt: 2025-01-07T13:06:55.837Z, editedAt: 2025-01-07T13:32:12.246Z, tag: , user: 67763d058b0c374bed083641, __v: 0}, {_id: 677d2d2169eb1515eb40baac, title: sda, details: sda에 대해 걱정하고 계신 것에 대해 이해합니다. 하지만 걱정할 필요는 없답니다. 인생에는 여러 가지 일이 있지만, 모든 문제는 해결될 수 있는 법이에요. 너무 심각하게 생각하지 마시고, 편안한 마음으로 상황을 바라보시면 좋겠습니다. 여러분께서 겪고 있는 감정도 너무 자연스러운 것이니, 자신을 잘 다독이시고 긍정적인 마음을 가지신다면 분명히 좋은 방향으로 나아가실 수 있을 것입니다. 항상 응원하고 있습니다!, additional_material: , createdAt: 2025-01-07T13:06:55.837Z, editedAt: 2025-01-07T13:33:21.658Z, tag: , user: 67763d058b0c374bed083641, __v: 0}, {_id: 677d2f1269eb1515eb40bb2c, title: asd, details: 안녕하세요! 걱정하고 계신 것에 대해 말씀해 주셔서 감사합니다. "asd"라는 걱정이 마음을 불편하게 하고 계신 것 같아 안타깝습니다. 하지만 정말로 걱정하실 필요는 없으세요. 우리가 느끼는 걱정은 때로는 이해하기 어려운 것이지만, 그럴 땐 잠시 숨을 고르고 마음의 평화를 찾아보는 것이 좋답니다. */