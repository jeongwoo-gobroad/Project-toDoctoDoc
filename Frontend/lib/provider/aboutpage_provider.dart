import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../auth/auth_dio.dart';


class AboutpageProvider extends GetxController{

  var aboutData = RxString("");
  var isLoading = false.obs;

  final Dio dio;

  AboutpageProvider({required this.dio});

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAboutPage();
    //dio.interceptors.add(CustomInterceptor());
  }

  Future<void> fetchAboutPage() async {
    isLoading.value = true;

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/about',
      options: Options(headers: {
        'Content-Type': 'application/json',
        //token?
      },
      ),
    );



    /*
    final response = await http.get(
      Uri.parse('http://jeongwoo-kim-web.myds.me:3000/mapp/about'),
      headers: {
        'Content-Type': 'application/json',
        //token?
      },
    );
     */

    if(response.statusCode==200){
      final data = json.decode(response.data);
      //print(data);
      aboutData.value = data['content']['string'];
      print(aboutData);
    }
    isLoading.value = false;
  }
}