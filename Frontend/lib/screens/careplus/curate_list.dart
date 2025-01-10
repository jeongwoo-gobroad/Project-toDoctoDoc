import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/pageView.dart';
import 'package:to_doc/ai_chat_oldview.dart';
import 'package:to_doc/controllers/aichat_load_controller.dart';
import 'package:to_doc/controllers/ai_chat_list_controller.dart';
import 'package:intl/intl.dart';

class CurationScreen extends StatefulWidget {
  final String currentId;
  const CurationScreen({required this.currentId});
  @override
  _CurationScreenState createState() => _CurationScreenState();
}

class _CurationScreenState extends State<CurationScreen>
    with SingleTickerProviderStateMixin {
  bool isPostExpanded = false;
  bool isAiExpanded = false;
  final CurateListController curateListController =
      Get.put(CurateListController());
  final ViewController viewController = Get.find<ViewController>();
  final AiChatListController aiChatListController =
      Get.put(AiChatListController());
  final ChatController chatController = Get.put(ChatController());
  final UserinfoController userinfoController = Get.find<UserinfoController>();

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toUtc().add(Duration(hours: 9));
      return DateFormat('yyyy년 M월 d일 HH시 mm분').format(dateTime);
    } catch (e) {
      return '날짜 정보 없음';
    }
  }

  //애니메이션
  late final AnimationController _animationController;
  final Map<String, bool> _isItemPressed = {};

  void togglePostExpansion() {
    setState(() {
      isPostExpanded = !isPostExpanded;
    });
  }

  void toggleAiExpansion() {
    setState(() {
      isAiExpanded = !isAiExpanded;
    });
  }
  Future<void> _onRefresh() async{
    await curateListController.getPost(widget.currentId);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _animateItem(String id, Future<void> Function() callback) async {
    setState(() => _isItemPressed[id] = true);

    try {
      await callback();
    } finally {
      if (mounted) {
        setState(() => _isItemPressed[id] = false);
      }
    }
  }

  Widget buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
    Color? backgroundColor,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.purple[100],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.purple[900],
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
          child: isExpanded ? content : Container(),
        ),
      ],
    );
  }

  Widget buildListItem({
    required String id,
    required String title,
    required Color backgroundColor,
    String? subtitle,
    required Future<void> Function() onTap,
  }) {
    bool isPressed = _isItemPressed[id] ?? false;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(
        begin: 0,
        end: isPressed ? 0.95 : 1.0,
      ),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: isPressed ? 1 : 2, //누를때 효과과
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: InkWell(
          onTap: () => _animateItem(id, onTap),
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: subtitle != null ? 100 : 80,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCommentCard(Map<String, dynamic> comment, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  comment['doctor']['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Text(
                  formatDate(comment['date']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment['content'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  print('doctor ID : ${comment['doctor']['_id']}');
                  print('user ID : ${userinfoController.id}');
                  //chatController.requestChat('67763d058b0c374bed083641', '677fbcfcd77a92c816208849');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '상담 요청',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("큐레이팅 화면"),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // 스크롤 이벤트 처리
          return true;
        },
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 포스트 드롭다운
                      buildExpandableSection(
                        title: "포스트",
                        isExpanded: isPostExpanded,
                        onToggle: togglePostExpansion,
                        content: Obx(() {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.decelerate,
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.decelerate,
                              child: isPostExpanded
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: curateListController.posts.length,
                                      itemBuilder: (context, index) {
                                        final post = curateListController.posts[index];
                                        return buildListItem(
                                          id: post['_id'],
                                          title: post['title'],
                                          backgroundColor: Colors.purple[50]!,
                                          onTap: () async {
                                            await viewController.getFeed(post['_id']);
                  
                                            Get.to(() => Pageview());
                                            //print("${post['title']} 클릭");
                                          },
                                        );
                                      },
                                    )
                                  : Container(),
                            ),
                          );
                        }),
                      ),
              
                      //챗
                      const SizedBox(height: 16),
              
                      // AI 챗 섹션
                      buildExpandableSection(
                        title: "AI 챗",
                        isExpanded: isAiExpanded,
                        onToggle: toggleAiExpansion,
                        backgroundColor: Colors.blue[100],
                        content: Obx(() {
                          return AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutQuart,
                            child: isAiExpanded
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: curateListController.chatList.length,
                                    itemBuilder: (context, index) {
                                      final chat = curateListController.chatList[index];
                                      return buildListItem(
                                        id: chat['_id'],
                                        title: chat['title'],
                                        //subtitle: chat['lastMessage'],
                                        backgroundColor: Colors.blue[50]!,
                                        onTap: () async {
                                          //await viewController.openAiChat(chat['_id']);
                                          Get.to(() => AiChatOldView(
                                                chatId: chat['_id'],
                                                chatTitle: (chat['title'] != null)
                                                    ? chat['title']
                                                    : '빈 제목',
                                              ))?.whenComplete(() {
                                            setState(() {
                                              aiChatListController.getChatList();
                                            });
                                          });
                                          print("${chat['title']} AI 챗 클릭됨");
                                        },
                                      );
                                    },
                                  )
                                : Container(),
                          );
                        }),
                      ),
              
                      //댓글
                      const SizedBox(height: 24),
              
                      // 댓글 섹션
                      const Text(
                        "큐레이팅 코멘트",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
              
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (curateListController.comments.isEmpty) {
                  return SliverToBoxAdapter(
                    child: const Text(
                      "코멘트가 없습니다.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comment = curateListController.comments[index];
                        return buildCommentCard(comment, index);
                      },
                      childCount: curateListController.comments.length,
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
