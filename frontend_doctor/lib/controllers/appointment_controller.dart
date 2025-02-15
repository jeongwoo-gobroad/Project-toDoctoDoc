import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'auth/auth_interceptor.dart';


class AppointmentController extends GetxController {
  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();

  late List<dynamic> appList;

  var isLoading = true.obs;
  var isBeforeAppExist = false;

  List<int> todayList = [];

  var nearAppointment = 0;
  var approvedAppointment = -1;

  late Map<String, dynamic> appointment;
  late Map<String, dynamic> hospital;

  Future<bool> getAppointmentList() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.get(
      '${Apis.baseUrl}mapp/doctor/appointment/list',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      appList = data['content'];

      print('APPOINTMENT LIST -------------');
      print(appList);

      if (data['content'].isEmpty) {
        isLoading.value = false;
        return false;
      }
      appList.sort((a, b) => a['appointmentTime'].compareTo(b['appointmentTime']));

      var index = 0;
      nearAppointment = 0;
      approvedAppointment = -1;

      for (var appointment in appList) {
        appointment['appointmentTime'] = DateTime.parse(appointment['appointmentTime']).toLocal();

        if (appointment['appointmentTime'].isBefore(DateTime.now())) {
          isBeforeAppExist = true;
          nearAppointment++;
        }
        else if (appointment['isAppointmentApproved'] && approvedAppointment == -1) {
          approvedAppointment = index;
        }
        index++;
      }

      print(nearAppointment);
      isLoading.value = false;
      return true;
    }
    else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> getSimpleInformation() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.get(
      '${Apis.baseUrl}mapp/doctor/appointment/simpleList',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      appList = data['content'];

      print('APPOINTMENT LIST -------------');
      print(appList);

      if (data['content'].isEmpty) {
        isLoading.value = false;
        return false;
      }

      appList.sort((a, b) => a['appointmentTime'].compareTo(b['appointmentTime']));

      todayList = [];
      int i = 0;
      nearAppointment = 0;
      for (var appointment in appList) {
        appointment['appointmentTime'] = DateTime.parse(appointment['appointmentTime']).toLocal();
        appointment['appointmentEndAt'] = DateTime.parse(appointment['appointmentEndAt']).toLocal();

        if (appointment['appointmentTime'].isBefore(DateTime.now())) {
          isBeforeAppExist = true;
          nearAppointment++;
        }
        if (appointment['appointmentTime'].day == DateTime.now().day) {
          todayList.add(i);
        }
        i++;
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
    dio.interceptors.add(customInterceptor);

    final response = await dio.get(
      '${Apis.baseUrl}mapp/doctor/appointment/get/$appointmentId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);

      appointment = data['content'];
      isLoading.value = false;

      return true;
    }
    else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> sendAppointmentIsDone(String appointmentId) async {
    print('APPOINTMENT ID ------ $appointmentId');

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    final response = await dio.post(
        '${Apis.baseUrl}mapp/doctor/appointment/done',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },),
        data: json.encode({
          'appid' : appointmentId,
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