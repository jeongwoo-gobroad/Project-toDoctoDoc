import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:to_doc_for_doc/controllers/curate/curate_controller.dart';
import 'package:intl/intl.dart';

class CurateDetailScreen extends StatefulWidget {
  @override
  State<CurateDetailScreen> createState() => _CurateDetailScreenState();
}

class _CurateDetailScreenState extends State<CurateDetailScreen> {
  final controller = Get.put(CurateController());

  //final String curateId;
  final TextEditingController commentController = TextEditingController();
  final TextEditingController editController = TextEditingController();

   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getCurateInfo('5');
  }
  //CurateDetailScreen({required this.curateId});
  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toUtc().add(Duration(hours: 9));
      return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('큐레이팅 상세'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final detail = controller.curateDetail.value;
        if (detail == null) {
          return Center(child: Text('데이터를 불러올 수 없습니다.'));
        }

        return CustomScrollView(
          slivers: [
           
            SliverToBoxAdapter(
              child: Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '요청일: ${formatDate(detail.createdAt)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '큐레이팅 내용',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '게시물',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = detail.posts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ExpansionTile(
                      title: Text(post.title),
                      subtitle: Text(
                        formatDate(post.createdAt),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '내용:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(post.details),
                              if (post.additionalMaterial.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  '추가 내용:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(post.additionalMaterial),
                              ],
                              if (post.tag.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Chip(
                                  label: Text(
                                    post.tag,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: detail.posts.length,
              ),
            ),

            //ai
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'AI 챗',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chat = detail.aiChats[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ExpansionTile(
                      title: Text(chat.title),
                      subtitle: Text(
                        '최근 메시지: ${chat.recentMessage}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: chat.response.length,
                          itemBuilder: (context, msgIndex) {
                            final message = chat.response[msgIndex];
                            return Container(
                              padding: EdgeInsets.all(8),
                              margin: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: message.role == 'assistant'
                                    ? Colors.blue[50]
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.role == 'assistant' ? 'AI' : '사용자',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: message.role == 'assistant'
                                          ? Colors.blue
                                          : Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(message.content),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
                childCount: detail.aiChats.length,
              ),
            ),

            // 댓글
            if (detail.comments.isNotEmpty)
              SliverToBoxAdapter(
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '댓글',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: detail.comments.length,
                          itemBuilder: (context, index) {
                            final comment = detail.comments[index];
                            final doctorName = comment.doctor.name;
                            final commentDate = formatDate(comment.date);
                                
                            final content = comment.content;
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            size: 16, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Text(
                                          doctorName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          commentDate,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      editController.text = content; //기존내용용
                                      Get.defaultDialog(
                                        title: '댓글 수정',
                                        content: TextField(
                                          controller: editController,
                                          decoration: InputDecoration(
                                            hintText: '수정할 내용을 입력하세요.',
                                          ),
                                        ),
                                        confirm: ElevatedButton(
                                          onPressed: () {
                                            final updatedContent =
                                                editController.text.trim();
                                            if (updatedContent.isNotEmpty) {
                                              //print(comment.id);
                                              controller.commentModify(comment.id ,detail.id,updatedContent);
                                              Get.back(); 
                                              
                                            } else {
                                              
                                            }
                                          },
                                          child: Text('수정'),
                                        ),
                                        cancel: TextButton(
                                          onPressed: () => Get.back(),
                                          child: Text('취소'),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      Get.defaultDialog(
                                        title: '댓글 삭제',
                                        middleText: '이 댓글을 삭제하시겠습니까?',
                                        confirm: ElevatedButton(
                                          onPressed: () {
                                            controller.commentDelete(comment.id, detail.id);
                                            Get.back(); 
                                          },
                                          child: Text('삭제'),
                                        ),
                                        cancel: TextButton(
                                          onPressed: () => Get.back(),
                                          child: Text('취소'),
                                        ),
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('수정'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('삭제'),
                                    ),
                                  ],
                                ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      content,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: '댓글을 입력하세요.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final newComment = commentController.text.trim();
                        if (newComment.isNotEmpty) {
                          //print(detail.id);
                          controller.addComment(detail.id, newComment);
                          commentController.clear();
                        } else {
                          Get.snackbar('오류', '댓글 내용을 입력하세요.');
                        }
                      },
                      child: Text('추가'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
