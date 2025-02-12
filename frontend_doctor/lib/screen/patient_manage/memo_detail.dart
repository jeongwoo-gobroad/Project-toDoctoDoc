import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:to_doc_for_doc/controllers/AIassistant/ai_assistant_controller.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_controller.dart';

class MemoDetailScreen extends StatefulWidget {
  const MemoDetailScreen({Key? key, required this.patientId}) : super(key: key);
  final String patientId;

  @override
  _MemoDetailScreenState createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends State<MemoDetailScreen> {
  final MemoController controller = Get.put(MemoController());
  int selectedColor = 0;

  AiAssistantController aiAssistantController =
      Get.put(AiAssistantController());
  final TextEditingController memoTextController = TextEditingController();
  final TextEditingController detailsTextController = TextEditingController();

  final ValueNotifier<int> memoCharCount = ValueNotifier<int>(0);
  final ValueNotifier<int> detailCharCount = ValueNotifier<int>(0);
  bool isGeneratingAnswer = false;

  @override
  void initState() {
    super.initState();
    print(widget.patientId);
    //print(memoController.memoDetail.value!.memo);
    aiAssistantController.assistantDailyLimit();
    memoTextController.text = controller.memoDetail.value!.memo;
    detailsTextController.text = controller.memoDetail.value!.details;

    detailCharCount.value = detailsTextController.text.length;
    memoCharCount.value = memoTextController.text.length;
    detailsTextController.addListener(() {
      detailCharCount.value = detailsTextController.text.length;
    });

    memoTextController.addListener(() {
      memoCharCount.value = memoTextController.text.length;
    });
  }

  @override
  void dispose() {
    memoTextController.dispose();
    detailsTextController.dispose();
    memoCharCount.dispose();
    super.dispose();
  }

  Widget _buildAiSummaryPrompt() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 225, 234, 205),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color.fromARGB(255, 255, 230, 0)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Ai 요약을 위해서 플로팅버튼을 눌러보세요.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '메모',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("유의"),
                content: const Text("100자 이상 적은 메모에 대해서만 입력 데이터를 생성합니다."),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (detailCharCount.value < 100) {
                        Navigator.of(context).pop();
                        Get.snackbar("실패", "100자 이상의 세부사항을 작성해주세요.");
                      } else {
                        Navigator.of(context).pop();
                        setState(() {
                          isGeneratingAnswer = true;
                        });
                        aiAssistantController.detailsSummary(widget.patientId);
                      }
                    },
                    child: const Text("확인"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("취소"),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text("AI 요약"),
        backgroundColor: Color.fromARGB(255, 225, 234, 205),
      ),
      body: Obx(() {
        if (controller.detailLoading.value == true) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isGeneratingAnswer
                  ? const LoadingAnimationText()
                  : _buildAiSummaryPrompt(),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '색상 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildColorButton(Colors.red, 0),
                          _buildColorButton(Colors.orange, 1),
                          _buildColorButton(Colors.yellow, 2),
                          _buildColorButton(Colors.green, 3),
                          _buildColorButton(Colors.blue, 4),
                          _buildColorButton(Colors.purple, 5),
                          _buildColorButton(Colors.brown, 6),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '메모 내용',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: memoTextController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                        decoration: const InputDecoration(
                          hintText: '메모를 입력하세요 (최대 500자)',
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder<int>(
                            valueListenable: memoCharCount,
                            builder: (context, count, child) {
                              return Text(
                                '$count/500자',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final updatedMemo = memoTextController.text;
                              bool result = await controller.editMemo(
                                widget.patientId,
                                selectedColor,
                                updatedMemo,
                              );
                              if (result) {
                                Get.snackbar('성공', '메모가 업데이트 되었습니다.');
                              } else {
                                Get.snackbar('실패', '메모 업데이트에 실패했습니다.');
                              }
                            },
                            child: const Text('메모 업데이트'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '세부사항',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: detailsTextController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: '세부사항을 입력하세요',
                            contentPadding: EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder<int>(
                            valueListenable: detailCharCount,
                            builder: (context, count, child) {
                              return Text(
                                '$count자',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final updatedDetails = detailsTextController.text;
                              bool result = await controller.editDetails(
                                widget.patientId,
                                updatedDetails,
                              );
                              if (result) {
                                Get.snackbar('성공', '세부사항이 업데이트 되었습니다.');
                              } else {
                                Get.snackbar('실패', '세부사항을 업데이트 하지 못했습니다.');
                              }
                            },
                            child: const Text('세부사항 업데이트'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildColorButton(Color color, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = index;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectedColor == index
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }
}

class LoadingAnimationText extends StatefulWidget {
  const LoadingAnimationText({Key? key}) : super(key: key);

  @override
  _LoadingAnimationTextState createState() => _LoadingAnimationTextState();
}

class _LoadingAnimationTextState extends State<LoadingAnimationText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 225, 234, 205),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color.fromARGB(255, 255, 230, 0)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "답변 생성중...",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}