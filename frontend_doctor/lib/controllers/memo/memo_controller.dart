import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';




class MemoController extends GetxController {
  var isLoading = true.obs;
 

  Future<bool> memoExists(String userId) async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      '${Apis.baseUrl}mapp/doctor/patientRecord/exists/$userId',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      
      isLoading.value = false;
      return true;
    }
    else if(response.statusCode == 201){
      isLoading.value = false;
      return false;
    }
    else{
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> getMemoList() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      '${Apis.baseUrl}mapp/doctor/patientRecord/list',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      List<dynamic> contentList = data['content'];
    List<String> idList = [];
    for (var item in contentList) {
      idList.add(item['_id']);
    }
    print("Extracted _id list: $idList");
      
      return true;
    }
  
    else{
      
      return false;
    }
  }

  Future<bool> getMemoDetail(String id) async {
    

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      '${Apis.baseUrl}mapp/doctor/patientRecord/details/$id',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);

      
      return true;
    }
  
    else{
      
      return false;
    }
  }

  Future<bool> writeMemo(String pid, int color, String memo, String details) async {

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.post(
      '${Apis.baseUrl}mapp/doctor/patientRecord/write',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
      data: json.encode({
          'pid' : pid,
          'color': color,
          'memo' : memo,
          'details': details,
      })
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);

      
      return true;
    }
  
    else{
      
      return false;
    }
  }

 
}