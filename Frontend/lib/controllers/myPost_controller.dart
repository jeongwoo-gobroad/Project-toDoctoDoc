import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class MypostController extends GetxController{

  var posts = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  

  Future<void> fetchMyPost() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if(token == null){

      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
      return;
    }

    isLoading.value = true;
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/myPosts'),
      headers: {
        'Content-Type':'application/json',
        'authorization':'Bearer $token',
      },
    );

    if(response.statusCode==200){
      final data = json.decode(json.decode(response.body));
      
      //print(data);
      
      if(data is Map<String,dynamic> && data['content'] is List){
        List<dynamic> contentList = data['content'];
        //데이터
        for(var post in contentList){
          posts.value = (data['content'] as List).map((e) => e as Map<String,dynamic>).toList();
          //print('Title: ${post['title']} Tag : ${post['tag']}');
        }
        //시간형식: "2025-01-02T11:17:48.062Z\"
      }
      

      //print('게시물 data: ${posts.value}');

      
    }
    else{

      Get.snackbar('Error', '게시물을 불러오지 못했습니다. ${response.statusCode})');
    }
    isLoading.value = false;


    /*TypeError: "{\"error\":false,\"result\":\"myposts\",\"content\":[{\"_id\":\"67767dfb6a4a8b2b5fe85785\",\"title\":\"만사가 귀찮아\",\"createdAt\":\"2025-01-02T11:17:48.062Z\",\"tag\":\"힘들어\"},{\"_id\":\"6778e0b96804ede7b7ae0b50\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:07:44.833Z\",\"tag\":\"\"},{\"_id\":\"6778e14f6804ede7b7ae0b71\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:07:44.833Z\",\"tag\":\"\"},{\"_id\":\"6778e27ce86459c4e32add96\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:23:04.415Z\",\"tag\":\"\"},{\"_id\":\"6778e2a5e86459c4e32adda6\",\"title\":\"마음이 아파\",\"createdAt\":\"2025-01-04T07:23:04.415Z\",\"tag\":\"\"},{\"_id\":\"6778e4cae19925a908da5d9a\",\"title\":\"혹시 통신이 되니?\",\"createdAt\":\"2025-01-04T07:32:47.960Z\",\"tag\":\"\"},{\"_id\":\"6778e4ece19925a908da5db9\",\"title\":\"혹시 통신이 되니?\",\"createdAt\":\"2025-01-04T07:32:47.960Z\",\"tag\":\"\"},{\"_id\":\"6778f95b5a158a9d6d819a0e\",\"title\":\"낯선 환경에서 생활하는게 걱정돼\",\"createdAt\":\"2025-01-04T08:54:27.801Z\",\"tag\":\"ㅇㅇ\"},{\"_id\":\"67790ae43e2e645912c03a7c\",\"title\":\"피곤해\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"\"},{\"_id\":\"67791a303e2e645912c03dab\",\"title\":\"마음이 힘들어\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"\"},{\"_id\":\"67791a9f3e2e645912c03df4\",\"title\":\"다른 걱정거리\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"걱정거리\"},{\"_id\":\"67791bed3e2e645912c03e69\",\"title\":\"테스트용입니다.\",\"createdAt\":\"2025-01-04T10:17:38.604Z\",\"tag\":\"testtotest\"}]}" */



    



  }


}