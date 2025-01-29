import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../auth/auth_dio.dart';

class AppointmentController extends GetxController {
  var isLoading = true.obs;
  late List<dynamic> appointmentList;
  var isAfterTodayAppointmentExist = true.obs;

  var nearAppointment = 0;
  var approvedAppointment = -1;

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

      if (data['content'].isEmpty) {
        isAfterTodayAppointmentExist.value = false;
        isLoading.value = false;
        return false;
      }

      appointmentList.sort((a, b) => a['appointmentTime'].compareTo(b['appointmentTime']));

      var index = 0;
      nearAppointment = 0;
      for (var appointment in appointmentList) {
        appointment['appointmentTime'] = DateTime.parse(appointment['appointmentTime']).toLocal();

        if (appointment['appointmentTime'].isBefore(DateTime.now())) {
          nearAppointment++;
        }
        else if (appointment['isAppointmentApproved'] && approvedAppointment == -1) {
          approvedAppointment = index;
        }
        index++;
      }

      if (appointmentList.length == nearAppointment) {
        isAfterTodayAppointmentExist.value = false;
      }
      else {
        isAfterTodayAppointmentExist.value = true;
      }


      isLoading.value = false;
      return true;
    }
    else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }


  Future<bool> getAppointmentInformation(String appointmentId) async {
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

  Future<bool> sendAppointmentReview(String appointmentId, int rating, String userScript) async {
    print('APPOINTMENT ID ------ $appointmentId');

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.post(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/appointment/review',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
      data: json.encode({
        'appid' : appointmentId,
        'rating': rating,
        'content' : userScript,
      })
    );


    if (response.statusCode == 200) {
      return true;
    }
    else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }


}