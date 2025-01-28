import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../auth/auth_dio.dart';

class AppointmentController extends GetxController {
  var isLoading = true.obs;
  late List<dynamic> appointmentList;
  var isAppointmentExisted = false.obs;

  var nearAppointment = 0;

  late Map<String, dynamic> appointment;
  late Map<String, dynamic> hospital;

  Future<bool> getAppointmentList() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/appointment/list',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      appointmentList = data['content'];

      print('APPOINTMENT LIST -------------');
      print(appointmentList);

      if (data['content'].isNotEmpty) {
        isAppointmentExisted.value = true;
      }

      appointmentList.sort((a, b) => a['appointmentTime'].compareTo(b['appointmentTime']));

      for (var appointment in appointmentList) {
        appointment['appointmentTime'] = DateTime.parse(appointment['appointmentTime']).toLocal();
      }

      isLoading.value = false;
      return true;
    }
    else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }


  Future<bool> getAppointmentInformation() async {
    print('---------------');
    print(appointmentList);
    var appointmentId = appointmentList[nearAppointment]['_id'];

    print('APPOINTMENT ID ------ $appointmentId');

    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/appointment/getWithAppid/$appointmentId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      //contentList = data['content'];

      appointment = data['content']['appointment'];
      hospital = data['content']['psy'];

      print(appointment);
      print(hospital);

      isLoading.value = false;
      return true;
    }
    else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }



}