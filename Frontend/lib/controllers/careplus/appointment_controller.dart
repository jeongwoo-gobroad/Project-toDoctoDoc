import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/auth_dio.dart';

class AppointmentController extends GetxController{
  final Dio dio;

  AppointmentController({required this.dio});

  @override
  void onInit() {
    super.onInit();
    dio.interceptors.add(CustomInterceptor());
  }

  Future<void> appointmentList() async {

    final response = await dio.get(
      '',
      options:
        Options(headers: {
          'Content-Type':'application/json',
          'accessToken': 'true',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
    }
    else{
      print('코드: ${response.statusCode}');
    }
  }






}