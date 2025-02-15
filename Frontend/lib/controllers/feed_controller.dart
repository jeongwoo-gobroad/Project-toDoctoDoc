import 'package:get/get.dart';
import 'dart:convert';

import '../auth/auth_dio.dart';
import 'package:dio/dio.dart';

class FeedController extends GetxController{
  var feedData = {}.obs;
  var isLoading = false.obs;

  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();


  Future<void> getFeed(String postId) async{
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    isLoading.value = true;

    final response = await dio.get(
      '${Apis.baseUrl}mapp/view/$postId',
      options: Options(
        headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },
      )
    );


    if(response.statusCode == 200){
      final data = json.decode(response.data);
      print(data);      
    }
    isLoading.value = false;
  }
}
