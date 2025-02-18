import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'auth/auth_interceptor.dart';

class Appointment {
  DateTime startTime;
  DateTime endTime;
  String userNick = '';
  String userId   = '';

  String id     = '';
  String chatId = '';
  bool isApproved     = false;
  bool isDone         = false;
  bool isFeedBackDone = false;
  Map<String, dynamic> feedback = {};

  Appointment({required this.userId, required this.userNick, required this.startTime, required this.endTime,
    required this.chatId, required this.id, required this.isApproved, required this.isDone, required this.isFeedBackDone, required this.feedback,
  });

  factory Appointment.simple({required data}) =>
      Appointment(
          userId:     data['user']['_id'],
          userNick:   data['user']['usernick'],
          startTime:  DateTime.parse(data['appointmentTime']).toLocal(),
          endTime:    DateTime.parse(data['appointmentEndAt']).toLocal(),

          chatId: '', id: '', feedback: {}, isFeedBackDone: false, isDone: false, isApproved: false
      );

  factory Appointment.normal({required data}) =>
      Appointment(
          userId: data['user']['_id'],
          userNick: data['user']['usernick'],
          startTime: DateTime.parse(data['appointmentTime']).toLocal(),
          endTime: DateTime.parse(data['appointmentEndAt']).toLocal(),

          id: data['_id'],
          chatId: data['chatId'],
          isApproved: data['isAppointmentApproved'],
          isDone: data['hasAppointmentDone'],
          isFeedBackDone: data['hasFeedbackDone'],
          feedback: data['feedback'] ?? {},
      );
}

class AppointmentController extends GetxController {
  CustomInterceptor customInterceptor = Get.find<CustomInterceptor>();

  //late List<dynamic> appList;
  String todayYM = DateFormat.yM().format(DateTime.now());
  int today = DateTime.now().day;

  var isTodayAppExist = false.obs;

  var isLoading = true.obs;
  var isBeforeAppExist = false;
  var nearAppointment = 0;
  var approvedAppointment = -1;

  late Map<String, dynamic> appointment;
  late List<Appointment> appList = [];

  late Map<String, dynamic> hospital;

  var orderedMap = <String, List<List<int>>>{};

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();


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
      //appList = data['content'];
      appList.clear();

      print('APPOINTMENT LIST -------------');
      //print(appList);

      if (data['content'].isEmpty) {
        isLoading.value = false;
        return false;
      }

      for (var appointment in data['content']) {
        Appointment nowApp = Appointment.normal(data: appointment);
        appList.add(nowApp);
      }
      appList.sort((a, b) => a.startTime.compareTo(b.startTime));

      var index = 0;
      nearAppointment = 0;
      approvedAppointment = -1;
      isBeforeAppExist = false;

      for (var appointment in appList) {
        if (appointment.startTime.isBefore(DateTime.now())) {
          isBeforeAppExist = true;
          nearAppointment++;
        }
        else if (appointment.isApproved && approvedAppointment == -1) {
          approvedAppointment = index;
        }
        index++;
      }

      if (orderedMap[todayYM]![today].isNotEmpty) {
        isTodayAppExist.value = true;
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
      orderedMap.clear();
      appList.clear();

      final data = json.decode(response.data);

      print('APPOINTMENT LIST -------------');

      if (data['content'].isEmpty) {
        isLoading.value = false;
        return false;
      }


      for (var appointment in data['content']) {
        Appointment nowApp = Appointment.simple(data: appointment);
        appList.add(nowApp);
      }
      appList.sort((a, b) => a.startTime.compareTo(b.startTime));

      int i = 0;
      nearAppointment = 0;
      for (var appointment in appList) {
        print(appointment.startTime);

        var nowYM = DateFormat.yM().format(appointment.startTime);
        orderedMap.putIfAbsent(nowYM, () => List.generate(32, (_) => List.empty(growable: true), growable: false));

        //print(orderedMap[nowYM]);
        print(appointment.startTime.day);
        orderedMap[nowYM]?[appointment.startTime.day].add(i);

        if (appointment.startTime.isBefore(DateTime.now())) {
          isBeforeAppExist = true;
          nearAppointment++;
        }
        i++;
      }

      print(orderedMap);

      if (orderedMap[todayYM]![today].isNotEmpty) {
        isTodayAppExist.value = true;
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