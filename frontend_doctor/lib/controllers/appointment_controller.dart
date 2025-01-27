import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';

class AppointmentController extends GetxController {
  AppointmentController({required this.userId, required this.chatId});

  var isLoading = true.obs;

  DateTime initialDay = DateTime.now();
  TimeOfDay initialTime = TimeOfDay.now();

  String appointmentId = '';

  final String chatId;
  final String userId;

  late DateTime appointmentTime;

  bool isAppointmentExisted = false;
  bool isAppointmentDone = false;


  @override
  void onInit() {
    super.onInit();
  }

  Future<bool> getAppointmentInformation(String appId) async {
    isAppointmentExisted = true;
    isLoading.value = true;

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
        appointmentTime = DateTime.parse(data['content']['appointmentTime']).toLocal();

        print('APPOINTMENT ID-------------- $appointmentId');
        print('USER ID--------------------- $userId');
        print('APPOINTMENT TIME------------ $appointmentTime');

        initialDay  = DateTime(appointmentTime.year,appointmentTime.month,appointmentTime.day);
        initialTime = TimeOfDay(hour: appointmentTime.hour, minute: appointmentTime.minute);

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


  Future<bool> makeAppointment(DateTime selectedDay) async{
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    isLoading.value = true;

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

        appointmentTime = selectedDay;
        initialDay  = DateTime(selectedDay.year,selectedDay.month,selectedDay.day);
        initialTime = TimeOfDay(hour: selectedDay.hour, minute: selectedDay.minute);

        isLoading.value = false;
        isAppointmentDone = false;
        isAppointmentExisted = true;
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

        isAppointmentDone = false;
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