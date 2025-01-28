import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc/auth/auth_dio.dart';

import '../../socket_service/chat_socket_service.dart';

class ChatAppointmentController extends GetxController{
  final ChatSocketService socketService;

  ChatAppointmentController(this.socketService, this.chatId);

  late String appointmentId = 'load';
  final String chatId;

  //late DateTime appointmentTime;
  var isLoading = true.obs;

  late Map<String,dynamic> hospital;
  late Map<String,dynamic> appointment;

  bool isAppointmentExisted  = false;
  bool isAppointmentDone     = false;
  bool isAppointmentApproved = false;

  Future<bool> getAppointmentInformation(String chatId) async {
    isLoading = true.obs;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/appointment/get/$chatId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);

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
      print(1);
      if (data['content']['psy'] != null) {
        hospital = data['content']['psy'];
      }
      else {
        hospital = {
          'a' : 'a',};
      }
      print(2);

      appointmentId=  data['content']['appointment']['_id'];
      print('APPOINTMENT ID-------------- $appointmentId');
      print('HOSPITAL-------------------- $hospital');

      isAppointmentExisted = true;
      isLoading.value = false;
      return true;
    } else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> sendAppointmentApproval() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.post(
      'http://jeongwoo-kim-web.myds.me:3000/mapp/careplus/appointment/approve',
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

      isAppointmentApproved = true;
      socketService.sendAppointmentApproval(chatId);
      isLoading.value = false;
      return true;
    }
    else{
      print('코드: ${response.statusCode}');
      return false;
    }
  }
}