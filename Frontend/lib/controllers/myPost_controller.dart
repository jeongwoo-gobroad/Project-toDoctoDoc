import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AboutpageProvider extends GetxController{

  var aboutData = RxString("");
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
      final data = json.decode(response.body);
      //print(data);
      aboutData.value = data['content'];
      print(aboutData);
    }
    isLoading.value = false;




    



  }


}