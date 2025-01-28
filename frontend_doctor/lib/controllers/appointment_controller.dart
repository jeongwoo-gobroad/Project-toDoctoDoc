import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';

import '../socket_service/chat_socket_service.dart';

class AppointmentController extends GetxController {
  AppointmentController({required this.userId, required this.chatId, required this.socketService});

  final ChatSocketService socketService;
  var isLoading = true.obs;

  DateTime initialDay = DateTime.now();
  TimeOfDay initialTime = TimeOfDay.now();

  late String appointmentId = 'load';

  final String chatId;
  final String userId;

  var temptime;
  late DateTime appointmentTime = DateTime(0);

  bool isAppointmentExisted = false;
  bool isAppointmentDone = false;
  bool isAppointmentApproved = false;

  Future<bool> getAppointmentInformation(String appId) async {
    isLoading.value = true;

    isAppointmentExisted = true;
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    print(appId);
    appointmentId = appId;

    try {
      final response = await dio.get(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/appointment/get/$appointmentId',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },),
      );

      if (response.statusCode == 200) {
        print('SUCCESS');

        final data = json.decode(response.data);
        print(data);

        appointmentId = data['content']['_id'];

        temptime = data['content']['appointmentTime'];
        print(temptime);
        appointmentTime = DateTime.parse(data['content']['appointmentTime']).toLocal();

        isAppointmentApproved = data['content']['isAppointmentApproved'];

        print('APPOINTMENT ID-------------- $appointmentId');
        print('USER ID--------------------- $userId');
        print('APPOINTMENT TIME------------ $appointmentTime');

        initialDay  = DateTime(appointmentTime.year,appointmentTime.month,appointmentTime.day);
        initialTime = TimeOfDay(hour: appointmentTime.hour, minute: appointmentTime.minute);
      }
    } catch (error) {
      print('An error occurred: $error');
      return false;
    }
    isLoading.value = false;
    return true;
  }

  Future<bool> makeAppointment(DateTime selectedDay) async{
    isLoading = true.obs;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    DateTime dayToUTC = selectedDay.toUtc();

    print('----------------$userId');
    print('----------------$chatId');
    print(dayToUTC.toIso8601String());

    try {
      final response = await dio.post(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/appointment/set',
        options: Options(headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },),
        data : json.encode({
          'cid' : chatId,
          'uid' : userId,
          'time': dayToUTC.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('SUCCESS');
        var data = json.decode(response.data);
        print(data);
        appointmentId = data['content']['_id'];
        print(appointmentId);

        socketService.sendAppointmentRefresh(chatId);

        appointmentTime = selectedDay;
        initialDay  = DateTime(selectedDay.year,selectedDay.month,selectedDay.day);
        initialTime = TimeOfDay(hour: selectedDay.hour, minute: selectedDay.minute);

        isAppointmentDone = false;
        isAppointmentExisted = true;
        isAppointmentApproved = false;

        isLoading.value = false;
        return true;

      } else {
        return false;
      }
    } catch (error) {
      print('An error occurred: $error');
      return false;
    }
  }

  Future<bool> deleteAppointment() async{
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    isLoading.value = true;

    print('----------------$userId');
    print('----------------$chatId');
    print('----------------$appointmentId');


    try {
      final response = await dio.delete(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/appointment/set',
        options: Options(headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },),
        data : json.encode({
          'cid' : chatId,
          'uid' : userId,
          'appid': appointmentId,
        }),
      );

      if (response.statusCode == 200) {
        print('SUCCESS');

        appointmentId = '';
        isAppointmentDone = false;
        isAppointmentExisted = false;
        isAppointmentApproved = false;

        socketService.sendAppointmentRefresh(chatId);

        isLoading.value = false;
        return true;

      } else {

        return false;
      }

    } catch (error) {
      print('An error occurred: $error');
      return false;
    }
  }

  Future<bool> editAppointment(DateTime selectedDay) async{
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    isLoading.value = true;

    DateTime dayToUTC = selectedDay.toUtc();

    print('----------------$appointmentId');
    print(dayToUTC.toIso8601String());

    try {
      final response = await dio.patch(
        'http://jeongwoo-kim-web.myds.me:3000/mapp/doctor/appointment/set',
        options: Options(headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },),
        data : json.encode({
          'appid' : appointmentId,
          'time': dayToUTC.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('SUCCESS');

        appointmentTime = selectedDay;
        initialDay  = DateTime(appointmentTime.year,appointmentTime.month,appointmentTime.day);
        initialTime = TimeOfDay(hour: appointmentTime.hour, minute: appointmentTime.minute);

        isAppointmentApproved = false;
        isAppointmentDone = false;

        socketService.sendAppointmentRefresh(chatId);
        isLoading.value = false;
        return true;

      } else {
        return false;
      }
    } catch (error) {
      print('An error occurred: $error');
      return false;
    }
  }
}