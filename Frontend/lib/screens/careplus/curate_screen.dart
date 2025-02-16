import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/careplus/chat_controller.dart';
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/controllers/view_controller.dart';
import 'package:to_doc/screens/chat/dm_list.dart';
import 'package:to_doc/screens/pageView.dart';
import 'package:intl/intl.dart';

import '../../controllers/aichat/ai_chat_list_controller.dart';
import '../aichat/ai_chat_oldview.dart';

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
      Get.find<CurateListController>();
  final ViewController viewController = Get.find<ViewController>();
  final AiChatListController aiChatListController =
      Get.put(AiChatListController());
  final ChatController chatController = Get.put(ChatController());
  final UserinfoController userinfoController = Get.find<UserinfoController>();

  String formatDate(String date) {
    try {
      DateTime dateTime = DateTime.parse(date).toLocal();
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

  Future<void> _onRefresh() async {
    await curateListController.getPost(widget.currentId);
    setState(() {});
  }

  asyncBefore() async {
    await aiChatListController.getChatList();
    await curateListController.getPost(widget.currentId);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    asyncBefore();
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                  (comment['doctor'] == null) ? '' : comment['doctor']['name'],
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
                  reQuestChat(comment['doctor']['_id']);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 225, 234, 205),
                  foregroundColor: Colors.black,
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

  void reQuestChat(String doctorId) async {
    await chatController.requestChat(doctorId);
    Get.to(() => DMList(
          controller: chatController,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("큐레이팅 화면"),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          return true;
        },
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() {
                    if (curateListController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 225, 234, 205),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.auto_awesome,
                                  color: Color.fromARGB(255, 255, 230, 0)),
                              SizedBox(width: 8),
                              Text(
                                "AI 요약",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            curateListController.deepCurate,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: togglePostExpansion,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "포스트 ${isPostExpanded ? '숨기기' : '보기 (${curateListController.posts.length})'}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Icon(isPostExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: ConstrainedBox(
                          constraints: isPostExpanded
                              ? const BoxConstraints()
                              : const BoxConstraints(maxHeight: 0),
                          child: Obx(() {
                            final int itemCount =
                                curateListController.posts.length;
                            double computedHeight =
                                (itemCount * 80.0 + 12).clamp(0.0, 300.0);
                            return Container(
                              margin: const EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 1),
                              ),
                              height: computedHeight,
                              child: itemCount > 0
                                  ? ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 12),
                                      itemCount: itemCount,
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        color: Colors.grey[400],
                                        thickness: 1.5,
                                        indent: 8,
                                        endIndent: 8,
                                      ),
                                      itemBuilder: (context, index) {
                                        final post =
                                            curateListController.posts[index];
                                        return Material(
                                          color: Colors.transparent,

                                          // onTap: () async {
                                          //   // 게시물 클릭 시 Feed 정보 불러오기 후 Pageview로 이동
                                          //   await viewController.getFeed(post['_id']);
                                          //   Get.to(() => Pageview());
                                          // },
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            splashColor:
                                                Colors.grey.withOpacity(0.3),
                                            onTap: () async {
                                              await viewController
                                                  .getFeed(post['_id']);
                                              Get.to(() => Pageview());
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    post['title'] ?? '제목 없음',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    post['details'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Text(
                                        "표시할 게시글이 없습니다.",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: toggleAiExpansion,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "AI 챗 ${isAiExpanded ? '숨기기' : '보기 (${curateListController.chatList.length})'}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Icon(isAiExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: ConstrainedBox(
                          constraints: isAiExpanded
                              ? const BoxConstraints()
                              : const BoxConstraints(maxHeight: 0),
                          child: Obx(() {
                            final int itemCount =
                                curateListController.chatList.length;
                            double computedHeight =
                                (itemCount * 80.0 + 12).clamp(0.0, 300.0);
                            return Container(
                              margin: const EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 1),
                              ),
                              height: computedHeight,
                              child: itemCount > 0
                                  ? ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 12),
                                      itemCount: itemCount,
                                      separatorBuilder: (context, index) =>
                                          Divider(
                                        color: Colors.grey[400],
                                        thickness: 1.5,
                                        indent: 8,
                                        endIndent: 8,
                                      ),
                                      itemBuilder: (context, index) {
                                        final chat = curateListController
                                            .chatList[index];
                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            splashColor:
                                                Colors.grey.withOpacity(0.3),
                                            onTap: () async {
                                              Get.to(() => AiChatOldView(
                                                    chatId: chat['_id'] ?? '',
                                                    chatTitle:
                                                        chat['title'] ?? '빈 제목',
                                                  ))?.whenComplete(() {
                                                setState(() {
                                                  aiChatListController
                                                      .getChatList();
                                                });
                                              });
                                              print(
                                                  "${chat['title']} AI 챗 클릭됨");
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    chat['title'] ?? '제목 없음',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    chat['recentMessage'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Text(
                                        "표시할 AI 챗이 없습니다.",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (curateListController.comments.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.comment, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            "댓글이 존재하지 않습니다.",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!, width: 1),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: curateListController.comments.length,
                        itemBuilder: (context, index) {
                          final comment = curateListController.comments[index];
                          return buildCommentCard(comment, index);
                        },
                      ),
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
