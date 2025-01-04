import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UploadController extends GetxController {
  var title = "".obs;
  var context = "".obs; // content 필드
  Future<void> uploadResult(String title, String content, String additionalContent, String tags) async {
    

    
    var body = {
      'title': title,
      'content': content,
      'content_additional': additionalContent,
      'tags': tags,
    };

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if(token == null){

      Get.snackbar('Login', '로그인이 필요합니다.');
      print('로그인이 필요합니다.');
    }
    // POST 요청 전송
    try {
      var response = await http.post(
        Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/upload'),
        
        body: json.encode(body), 
        
        
        headers: {
        'Content-Type': 'application/json',
        'authorization':'Bearer $token',
      });

      if (response.statusCode == 200) {
        
        Get.snackbar("성공", "결과가 성공적으로 공유되었습니다!");
      } else {
        
        Get.snackbar("오류", "결과 공유에 실패했습니다. 다시 시도해주세요.");
      }
    } catch (e) {
      
      Get.snackbar("오류", "문제가 발생했습니다. 다시 시도해주세요.");
    }
  }
}