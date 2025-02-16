import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/careplus/curate_list_controller.dart';
import 'package:to_doc/screens/careplus/nearby_curate_screen.dart';

class CuratePreview extends StatefulWidget {
  const CuratePreview({Key? key}) : super(key: key);

  @override
  _CuratePreviewState createState() => _CuratePreviewState();
}

class _CuratePreviewState extends State<CuratePreview>
    with SingleTickerProviderStateMixin {
  final CurateListController curateListController = Get.find<CurateListController>();
  bool isPostExpanded = false;
  bool isAiChatExpanded = false;

  @override
  Widget build(BuildContext context) {
    const String previewTitle = "큐레이팅 미리보기";

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      previewTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            curateListController.deepCurateNew,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isPostExpanded = !isPostExpanded;
                        });
                      },
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
                              "포스트 ${isPostExpanded ? '숨기기' : '보기'}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              isPostExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
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
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 220,
                          child: curateListController.postsNew.isNotEmpty
                              ? ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 12),
                                  itemCount:
                                      curateListController.postsNew.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    color: Colors.grey,
                                    height: 16,
                                  ),
                                  itemBuilder: (context, index) {
                                    final post =
                                        curateListController.postsNew[index];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post['title'] ?? '제목 없음',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          post['details'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    "표시할 게시글이 없습니다.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isAiChatExpanded = !isAiChatExpanded;
                        });
                      },
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
                              "AI 채팅 ${isAiChatExpanded ? '숨기기' : '보기'}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              isAiChatExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      child: ConstrainedBox(
                        constraints: isAiChatExpanded
                            ? const BoxConstraints()
                            : const BoxConstraints(maxHeight: 0),
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: 220,
                          child: curateListController.chatListNew.isNotEmpty
                              ? ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 12),
                                  itemCount:
                                      curateListController.chatListNew.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    color: Colors.grey,
                                    height: 16,
                                  ),
                                  itemBuilder: (context, index) {
                                    final chat =
                                        curateListController.chatListNew[index];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chat['title'] ?? '제목 없음',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          chat['recentMessage'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    "표시할 AI 채팅이 없습니다.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.to(() => const NearbyCurateScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 225, 234, 205),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "맞춤병원 찾기",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "취소",
                      style:
                          TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
