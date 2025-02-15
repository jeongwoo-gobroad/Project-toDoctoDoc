import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/auth_dio.dart';

class HospitalVisitedController extends GetxController{
  var isLoading = true.obs;
  late List<dynamic> hospitals;

  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();


  Future<bool> getVisitedHospitals() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.get(
      '${Apis.baseUrl}mapp/review/visited',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      print('HOSPITAL');
      final data = json.decode(response.data);
      print(data);

      hospitals = data['content'];

      isLoading.value = false;
      print('end hospital');

      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }
}