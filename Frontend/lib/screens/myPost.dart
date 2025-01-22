import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc/controllers/myPost_controller.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/navigation_menu.dart';
import 'package:to_doc/screens/pageView.dart';

class MypostTemp extends StatefulWidget {
  const MypostTemp({super.key});

  @override
  State<MypostTemp> createState() => _MypostTempState();
}

class _MypostTempState extends State<MypostTemp> {
  final ViewController viewController = Get.put(ViewController(dio:Dio()));
  final MypostController myPostController = Get.put(MypostController(dio: Dio()));

  @override
  void initState() {
    super.initState();
    myPostController.fetchMyPost();
  }

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toLocal();
      return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }

  Future<void> _onRefresh() async {
    await myPostController.fetchMyPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 게시물'),
        leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      Get.offAll(()=> NavigationMenu());
    },),
      ),
      
      body: Obx(() {
        if (myPostController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (myPostController.posts.isEmpty) {
          return const Center(
            child: Text('게시물이 없습니다.'),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.separated(
            itemCount: myPostController.posts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final post = myPostController.posts[index];
              return PostListTile(
                post: post,
                onTap: () async {
                  await viewController.getFeed(post['_id']);
                  Get.to(() => Pageview());
                },
                formatDate: formatDate,
              );
            },
          ),
        );
      }),
    );
  }
}

class PostListTile extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;
  final String Function(String) formatDate;

  const PostListTile({
    Key? key,
    required this.post,
    required this.onTap,
    required this.formatDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post['tag'] != null && post['tag'].isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                //vertical: 4,
                //horizontal: 8,
              ),
              decoration: BoxDecoration(
                //color: Colors.blue[50],
                //borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#${post['tag']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          Text(
            post['title'] ?? '제목 없음',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
/*            Text(
              '${post['details']}',
              overflow: TextOverflow.ellipsis,
            ),*/

            SizedBox(height: 4),
            Text(
              '작성일: ${formatDate(post['createdAt'] ?? '')}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }
}
