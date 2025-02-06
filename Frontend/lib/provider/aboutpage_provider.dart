import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../auth/auth_dio.dart';


class AboutpageProvider extends GetxController{
  var aboutData = RxString("");
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAboutPage();
  }

  Future<void> fetchAboutPage() async {
    Dio dio = Dio();

    isLoading.value = true;

    final response = await dio.get(
      '${Apis.baseUrl}mapp/about',
      options: Options(headers: {
        'Content-Type': 'application/json',
        //token?
      },),
    );

    if(response.statusCode==200){
      final data = response.data;
      print(data);
      aboutData.value = data['content']['string'];
      print(aboutData);
    }
    isLoading.value = false;
  }
}