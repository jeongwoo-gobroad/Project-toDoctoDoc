import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/AIassistant/ai_assistant_controller.dart';
import 'package:to_doc_for_doc/controllers/auth/auth_interceptor.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_detail_model.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_model.dart';




class MemoController extends GetxController {
  var isLoading = true.obs;
  RxString memoID = "".obs;
  AiAssistantController aiAssistantController = Get.find<AiAssistantController>();

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
      memoID.value = data['content']['memoId'];
    
      
      
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
  RxBool memoLoading = false.obs;
  RxList<Memo> memoList = <Memo>[].obs;
  Future<bool> getMemoList() async {
    memoLoading.value = true;
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
      var list = (data['content'] as List)
          .map((item) => Memo.fromJson(item))
          .toList();
      memoList.assignAll(list);
      
      print(memoList);

      //List<dynamic> contentList = data['content'];
    // List<String> idList = [];
    // for (var item in contentList) {
    //   idList.add(item['_id']);
    // }
    // print("Extracted _id list: $idList");
      memoLoading.value = false;
      return true;
    }
  
    else{
      memoLoading.value = false;
      return false;
    }
    
  }
  RxBool detailLoading = false.obs;
  RxList<MemoDetail> MemoDetailList = <MemoDetail>[].obs;
  Rx<MemoDetail?> memoDetail = Rx<MemoDetail?>(null);
  Future<bool> getMemoDetail(String id) async {
    detailLoading.value = true;

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
      final memo = data['content'];
      memoDetail.value = MemoDetail.fromJson(memo);
      print(memoDetail.value);
      if(memo['aiSummary'] != null){
        print('not null');
        aiAssistantController.summary.value = memo['aiSummary'];
        print(aiAssistantController.summary.value);
      }else{
        aiAssistantController.summary.value = "";
      }
      
      detailLoading.value = false;
      return true;
    }
  
    else{
      detailLoading.value = false;
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
  Future<bool> editMemo(String pid, int color, String memo) async {

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.patch(
      '${Apis.baseUrl}mapp/doctor/patientRecord/editMemo/$pid',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
      data: json.encode({
          'color': color,
          'memo' : memo,
      })
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);

      await getMemoList();
      return true;
    }
  
    else{
      
      return false;
    }
  }

  Future<bool> editDetails(String pid, String details) async {

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.patch(
      '${Apis.baseUrl}mapp/doctor/patientRecord/editDetails/$pid',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
      data: json.encode({
          'details': details,
      })
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      await getMemoList();
      //await getMemoDetail(pid);
      return true;
    }
  
    else{
      
      return false;
    }
  }
  Future<bool> deleteMemo(String pid) async {

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.delete(
      '${Apis.baseUrl}mapp/doctor/patientRecord/delete/$pid',
      options: Options(headers: {
        'Content-Type': 'application/json',
        'accessToken': 'true',
      },),
    
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      await getMemoList();
      //await getMemoDetail(pid);
      return true;
    }
  
    else{
      
      return false;
    }
  }

 
}