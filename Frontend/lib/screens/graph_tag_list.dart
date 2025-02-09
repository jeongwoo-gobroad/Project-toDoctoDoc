import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/graph_controller.dart';

class GraphTagList extends StatefulWidget {
  const GraphTagList({super.key});

  @override
  State<GraphTagList> createState() => _GraphTagListState();
}

class _GraphTagListState extends State<GraphTagList> {
  final TagGraphController tagGraphController = Get.put(TagGraphController(dio: Dio()));
  final Color _accentColor = const Color.fromARGB(255, 80, 110, 80);
  final Color _themeColor = const Color.fromARGB(255, 225, 234, 205);

  @override
  void initState() {
    tagGraphController.getBannedTags();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '차단된 태그 목록',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: _themeColor,
        elevation: 4,
      ),
      body: Obx(() {
        if (tagGraphController.getTagLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (tagGraphController.bannedTagsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block_rounded,
                  size: 80,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  '차단된 태그가 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tagGraphController.bannedTagsList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(
                  Icons.label_outlined,
                  color: _accentColor,
                ),
                title: Text(
                  tagGraphController.bannedTagsList[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: Colors.red.withOpacity(0.8),
                  ),
                  onPressed: () => _showTagDialog(tagGraphController.bannedTagsList[index]),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showTagDialog(String tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('태그 차단 해제', style: TextStyle(color: _accentColor)),
        content: Text("'$tag' 태그의 차단을 해제하시겠습니까?"),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              tagGraphController.tagUnBan(tag);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
            ),
            child: Text('해제', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          
        ],
      ),
    );
  }
}