import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/auth_dio.dart';

import '../../socket_service/chat_socket_service.dart';

class ChatAppointmentController extends GetxController{
  ChatAppointmentController();

  late String appointmentId = 'load';
  var isLoading = true.obs;
  late Map<String,dynamic> appointment;

  bool isAppointmentExisted  = false;
  bool isAppointmentDone     = false;
  bool isAppointmentApproved = false;

  Future<bool> getAppointmentInformation(String chatId) async {
    //isLoading.value = true;
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      '${Apis.baseUrl}mapp/careplus/appointment/get/$chatId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);

      if (data['content']['appointment'] == null) {
        isAppointmentExisted = false;
        isLoading.value = false;
        return true;
      }

      appointment = data['content']['appointment'];
      appointment['appointmentTime'] = DateTime.parse(appointment['appointmentTime']).toLocal();

      if (appointment['appointmentTime'].isBefore(DateTime.now())) {
        isAppointmentExisted = false;
        isLoading.value = false;
        return false;
      }

      isAppointmentApproved = data['content']['appointment']['isAppointmentApproved'];

      appointmentId=  data['content']['appointment']['_id'];
      print('APPOINTMENT ID-------------- $appointmentId');
      //print('HOSPITAL-------------------- $hospital');

      isAppointmentExisted = true;
      isLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> sendAppointmentApproval() async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.post(
      '${Apis.baseUrl}mapp/careplus/appointment/approve',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
      data: json.encode({
        'appid' : appointmentId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      isLoading.value = true;
      //isAppointmentApproved = true;
      return true;
    }
    else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }
}