import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/careplus/curating_model.dart';
import 'dart:convert';
import 'package:to_doc/controllers/userInfo_controller.dart';

import '../../auth/auth_dio.dart';

class CurateListController extends GetxController {
  var isLoading = true.obs;

  RxBool isPremium = false.obs;
  var CurateList = <Map<String, dynamic>>[].obs;
  var chatList   = <Map<String, dynamic>>[].obs;
  var comments   = <Map<String, dynamic>>[].obs;
  var posts      = <Map<String, dynamic>>[].obs;

  UserinfoController userinfoController = Get.put(UserinfoController());

  String deepCurate = 'null';

  Future<void> getList() async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      '${Apis.baseUrl}mapp/careplus/list',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print('------------data');
      print(data);
      final ids = (data['content'] as List).map((item) => item['_id']).toList();
      print('------------ids');

      print(ids); // _id 값 리스트 출력

      if (data['content'] is List) {
        List<dynamic> contentList = data['content'];
        //데이터
        for (var post in contentList) {
          CurateList.value = (data['content'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
          //print('Title: ${post['title']} Tag : ${post['tag']}');
        }
        CurateList.value.sort((a, b) {
          DateTime dateA = DateTime.parse(a['date']);
          DateTime dateB = DateTime.parse(b['date']);
          return dateB.compareTo(dateA); // 최신순 정렬
        });

        CurateList.refresh();

        print('curatelist----------------');
        print(CurateList.value);
      }
      //print(content);

      isLoading.value = false;
    }
  }

  Future<void> getPost(String id) async {
    isLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    // try {
    final response = await dio.get(
      '${Apis.baseUrl}mapp/careplus/post/$id',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      //final posts = data['content']['posts'] as List;
      if (data['content'] == null) {
        isLoading.value = false;
        return;
      }

      deepCurate = 'AI 요약이 없습니다';
      if (data['content']['posts'] is List) {
        posts.value = (data['content']['posts'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
      if (data['content']['ai_chats'] is List) {
        chatList.value = (data['content']['ai_chats'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
      if (data['content']['comments'] is List) {
        comments.value = (data['content']['comments'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
      if (data['content']['deepCurate'] != null) {
        deepCurate = data['content']['deepCurate'];
        print(deepCurate);
      }

      print('comment-----------------');
      print(comments);
      //print(posts);

      //print(content);
    }

    isLoading.value = false;
  }

  Future<void> requestCurate() async {
    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.post(
      '${Apis.baseUrl}mapp/careplus/curate',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },
      ),
    );


    print('request curate 진입');
    print('curate response body: ${response.data}');
    print('curate response code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      
      //print(content);
    }
  }
  RxBool nearbyLoading = false.obs;
  RxList<Content> curatedList = <Content>[].obs;
  Future<void> nearbyCurating(double fastWeight, double distWeight, double starWeight) async {
    nearbyLoading.value = true;

    Dio dio = Dio();
    dio.interceptors.add(CustomInterceptor());

    final response = await dio.get(
      '${Apis.baseUrl}mapp/v2/user/curate/nearbyCurating?fastWeight=$fastWeight&distWeight=$distWeight&starWeight=$starWeight&radius=5',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'accessToken': 'true',
        },
      ),
    );


    
    print('curate response code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.data);
      print(data);
      List<dynamic> contents = data['content'];
      //print(contents);
      List<Content> contentList = contents.map((json) => Content.fromJson(json)).toList();
      curatedList.assignAll(contentList);
      nearbyLoading.value = false;
    }
    nearbyLoading.value = false;
  }
}
/*혹시 어떤 부분이 특히 걱정이 되시는지 말씀해 주시면, 더 구체적으로 도와드릴 수 있을 것 같습니다. 긍정적인 마음으로 하루하루를 지나가다 보면, 분명 좋은 변화가 있을 거예요. 당신은 잘하고 계시니, 자신을 믿어보세요!, additional_material: , createdAt: 2025-01-07T13:06:55.837Z, editedAt: 2025-01-07T13:32:12.246Z, tag: , user: 67763d058b0c374bed083641, __v: 0}, {_id: 677d2d2169eb1515eb40baac, title: sda, details: sda에 대해 걱정하고 계신 것에 대해 이해합니다. 하지만 걱정할 필요는 없답니다. 인생에는 여러 가지 일이 있지만, 모든 문제는 해결될 수 있는 법이에요. 너무 심각하게 생각하지 마시고, 편안한 마음으로 상황을 바라보시면 좋겠습니다. 여러분께서 겪고 있는 감정도 너무 자연스러운 것이니, 자신을 잘 다독이시고 긍정적인 마음을 가지신다면 분명히 좋은 방향으로 나아가실 수 있을 것입니다. 항상 응원하고 있습니다!, additional_material: , createdAt: 2025-01-07T13:06:55.837Z, editedAt: 2025-01-07T13:33:21.658Z, tag: , user: 67763d058b0c374bed083641, __v: 0}, {_id: 677d2f1269eb1515eb40bb2c, title: asd, details: 안녕하세요! 걱정하고 계신 것에 대해 말씀해 주셔서 감사합니다. "asd"라는 걱정이 마음을 불편하게 하고 계신 것 같아 안타깝습니다. 하지만 정말로 걱정하실 필요는 없으세요. 우리가 느끼는 걱정은 때로는 이해하기 어려운 것이지만, 그럴 땐 잠시 숨을 고르고 마음의 평화를 찾아보는 것이 좋답니다. */