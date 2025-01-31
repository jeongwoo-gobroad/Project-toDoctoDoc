import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/auth_dio.dart';

class HospitalVisitedController extends GetxController{
  var isLoading = true.obs;

  var isVisitedHospitalExisted = false.obs;
  //late List<dynamic> hospitals = [];
  late List<dynamic> hospitals;

  Future<bool> getVisitedHospitals() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/review/visited',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      print('SUCCESS GET');
      final data = json.decode(response.data);
      print(data);

      if (data['content'].length == 0) {
        isVisitedHospitalExisted.value = false;
        isLoading.value = false;

        print('NO HOSPITAL EXISTED');

        return true;
      }

      // TODO MY HOSPITAL LIST
      isVisitedHospitalExisted.value = true;
      hospitals = data['content'];

/*      if (data['content'] == null) {
        isMyReviewExisted = false;
        return true;
      }

      List<dynamic> myReviews = data['content'];

      print(myReviews);*/

      isLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }
}