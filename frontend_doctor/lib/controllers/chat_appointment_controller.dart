import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';

class ChatAppointmentController extends GetxController {
  ChatAppointmentController({required this.userId, required this.chatId});
  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();

  var isLoading = true.obs;

  DateTime initialDay = DateTime.now();
  TimeOfDay initialTime = TimeOfDay.now();
  TimeOfDay initialEndTime = TimeOfDay.now();

  late String appointmentId = 'load';

  final String chatId;
  final String userId;

  var temptime;
  late Rx<DateTime> appointmentTime = DateTime(0).obs;
  late Rx<DateTime> appointmentEndTime = DateTime(0).obs;

   RxBool isAppointmentExisted = false.obs;
   RxBool isAppointmentDone = false.obs;
   RxBool isAppointmentApproved = false.obs;

  Future<bool> getAppointmentInformation(String chatId) async {
    //isLoading.value = true;
    //isAppointmentExisted = true;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    //try {
      final response = await dio.get(
        '${Apis.baseUrl}mapp/doctor/appointment/getWithChatId/$chatId',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },),
      );

      if (response.statusCode == 200) {
        print('SUCCESS');

        final data = json.decode(response.data);
        print(data);

        if (data['content'] == null) {
          isAppointmentExisted.value = false;
          isLoading.value = false;
          return true;
        }


        appointmentId = data['content']['_id'];
        appointmentTime.value = DateTime.parse(data['content']['appointmentTime']).toLocal();
        appointmentEndTime.value = DateTime.parse(data['content']['appointmentEndAt']).toLocal();

        isAppointmentApproved.value = data['content']['isAppointmentApproved'];
        isAppointmentDone.value = data['content']['hasAppointmentDone'];


        print(isAppointmentApproved);
        print(isAppointmentDone);

        print('APPOINTMENT ID-------------- $appointmentId');
        print('USER ID--------------------- $userId');
        print('APPOINTMENT TIME------------ ${appointmentTime.value}');

        isAppointmentExisted.value = true;
        isLoading.value = false;

        initialDay  = DateTime(appointmentTime.value.year,appointmentTime.value.month,appointmentTime.value.day);
        initialTime = TimeOfDay(hour: appointmentTime.value.hour, minute: appointmentTime.value.minute);
        initialEndTime = TimeOfDay(hour: appointmentEndTime.value.hour, minute: appointmentEndTime.value.minute);
      }
      else if (response.statusCode == 201) {
        isAppointmentExisted.value = false;
        isLoading.value = false;
        return true;
      }
/*    }
    catch (error) {
      print('An error occurred: $error');
      return false;
    }*/
    isLoading.value = false;
    return true;
  }

  Future<bool> makeAppointment(DateTime selectedDay, DateTime endTime) async{
    //isLoading = true.obs;

    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    DateTime dayToUTC = selectedDay.toUtc();
    DateTime endDayToUTC = endTime.toUtc();

    print('----------------$userId');
    print('----------------$chatId');
    print(dayToUTC.toIso8601String());
    print(endDayToUTC.toIso8601String());

    try {
      final response = await dio.post(
        '${Apis.baseUrl}mapp/doctor/appointment/set',
        options: Options(headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },),
        data : json.encode({
          'cid' : chatId,
          'uid' : userId,
          'time': dayToUTC.toIso8601String(),
          'endTime' : endDayToUTC.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('SUCCESS');
        isLoading.value = true;

        initialDay  = DateTime(selectedDay.year,selectedDay.month,selectedDay.day);
        initialTime = TimeOfDay(hour: selectedDay.hour, minute: selectedDay.minute);
        initialEndTime = TimeOfDay(hour: endTime.hour, minute: endTime.minute);

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
    dio.interceptors.add(customInterceptor);

    //isLoading.value = true;

    print('----------------$userId');
    print('----------------$chatId');
    print('----------------$appointmentId');


    try {
      final response = await dio.delete(
        '${Apis.baseUrl}mapp/doctor/appointment/set',
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
        isLoading.value = true;

        initialDay     = DateTime.now();
        initialTime    = TimeOfDay.now();
        initialEndTime = TimeOfDay.now();

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

  Future<bool> editAppointment(DateTime selectedDay, DateTime endTime) async{
    Dio dio = Dio();
    dio.interceptors.add(customInterceptor);

    isLoading.value = true;

    DateTime dayToUTC = selectedDay.toUtc();
    DateTime endDayToUTC = endTime.toUtc();

    print('----------------$appointmentId');
    print(dayToUTC.toIso8601String());

    try {
      final response = await dio.patch(
        '${Apis.baseUrl}mapp/doctor/appointment/set',
        options: Options(headers: {
          'Content-Type':'application/json',
          'accessToken':'true',
        },),
        data : json.encode({
          'appid' : appointmentId,
          'time': dayToUTC.toIso8601String(),
          'length' : endDayToUTC.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('SUCCESS');

        isLoading.value = true;
        initialDay  = DateTime(selectedDay.year,selectedDay.month,selectedDay.day);
        initialTime = TimeOfDay(hour: selectedDay.hour, minute: selectedDay.minute);
        initialEndTime = TimeOfDay(hour: endTime.hour, minute: endTime.minute);

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