import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:to_doc_for_doc/controllers/AIassistant/ai_assistant_controller.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_controller.dart';

class MemoDetailScreen extends StatefulWidget {
  const MemoDetailScreen(
      {Key? key, required this.patientId, required this.selectedColor})
      : super(key: key);
  final String patientId;
  final int selectedColor;

  @override
  _MemoDetailScreenState createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends State<MemoDetailScreen> {
  final MemoController controller = Get.put(MemoController());
  int selectColor = 0;

  AiAssistantController aiAssistantController =
      Get.find<AiAssistantController>();
  final TextEditingController memoTextController = TextEditingController();
  final TextEditingController detailsTextController = TextEditingController();

  final ValueNotifier<int> memoCharCount = ValueNotifier<int>(0);
  final ValueNotifier<int> detailCharCount = ValueNotifier<int>(0);
  bool isGeneratingAnswer = false;
  bool _isDetailsExpanded = false;
  bool _isEditingDetails = false;
  bool _animateNewSummary = false;
  String _oldSummary = '';
  double _buttonOpacity = 1.0;
  Timer? _fadeTimer;
  @override
  void initState() {
    super.initState();
     _resetFadeTimer();
    _oldSummary = aiAssistantController.summary.value;

    print('summary: ${aiAssistantController.summary}');
    selectColor = widget.selectedColor;
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
    _fadeTimer?.cancel();
    memoTextController.dispose();
    detailsTextController.dispose();
    memoCharCount.dispose();
    super.dispose();
  }
  void _resetFadeTimer() {
    _fadeTimer?.cancel();

    setState(() {
      _buttonOpacity = 1.0;
    });

    _fadeTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _buttonOpacity = 0.3;
      });
    });
  }

  Widget _buildQueryUsageDisplay() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 225, 234, 205),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '일일 제한 횟수: ${aiAssistantController.patientTotal.value}/${aiAssistantController.dailyPatientLimit}',
            style: TextStyle(
              fontSize: 14,
              color: aiAssistantController.patientTotal.value >=
                      aiAssistantController.dailyPatientLimit
                  ? Colors.red
                  : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ));
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
          const Icon(Icons.lightbulb_outline,
              color: Color.fromARGB(255, 255, 230, 0)),
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
      floatingActionButton: AnimatedOpacity(
        opacity: _buttonOpacity,
        duration: Duration(seconds: 1),
        child: FloatingActionButton.extended(
          onPressed: () {
            _resetFadeTimer();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("유의"),
                  content: const Text("100자 이상 적은 세부사항에 대해서만 입력 데이터를 생성합니다."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (detailCharCount.value < 100) {
                          Navigator.of(context).pop();
                          Get.snackbar("실패", "100자 이상의 세부사항을 작성해주세요.");
                        } else if (aiAssistantController.patientLimited.value ==
                            true) {
                          Navigator.of(context).pop();
                          Get.snackbar("실패", "일일제한 횟수를 초과하였습니다.");
                        } else {
                          Navigator.of(context).pop();
                          setState(() {
                            isGeneratingAnswer = true;
                            aiAssistantController.summary.value = "";
                          });
                          aiAssistantController
                              .detailsSummary(widget.patientId)
                              .then((_) {
                            setState(() {
                              isGeneratingAnswer = false;
                              if (aiAssistantController.summary.value !=
                                  _oldSummary) {
                                _oldSummary = aiAssistantController.summary.value;
                                _animateNewSummary = true;
                              } else {
                                _animateNewSummary = false;
                              }
                            });
                          });
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
      ),
      body: Obx(() {
        if (controller.detailLoading.value == true) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQueryUsageDisplay(),
              const SizedBox(height: 3),
              Obx(() {
                if (aiAssistantController.summary.value.isNotEmpty) {
                  if (_animateNewSummary) {
                    return AnimatedSummaryText(
                      text: aiAssistantController.summary.value,
                      onAnimationComplete: () {
                        setState(() {
                          _animateNewSummary = false;
                        });
                      },
                    );
                  } else {
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
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            aiAssistantController.summary.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else if (isGeneratingAnswer) {
                  return const LoadingAnimationText();
                } else {
                  return _buildAiSummaryPrompt();
                }
              }),
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
                      const SizedBox(height: 16),
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
                                selectColor,
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
                      _isEditingDetails
                          ? TextFormField(
                              controller: detailsTextController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                hintText: '세부사항을 입력하세요',
                                contentPadding: EdgeInsets.all(16),
                                border: InputBorder.none,
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                detailsTextController.text,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditingDetails = !_isEditingDetails;
                              });
                            },
                            child: Text(_isEditingDetails ? "접기" : "더보기"),
                          ),
                          if (_isEditingDetails)
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
          selectColor = index;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selectColor == index
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
                  const Icon(Icons.lightbulb_outline,
                      color: Color.fromARGB(255, 255, 230, 0)),
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

class AnimatedSummaryText extends StatefulWidget {
  final String text;
  final Duration duration;
  final VoidCallback? onAnimationComplete;
  const AnimatedSummaryText({
    Key? key,
    required this.text,
    this.duration = const Duration(milliseconds: 1500),
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  _AnimatedSummaryTextState createState() => _AnimatedSummaryTextState();
}

class _AnimatedSummaryTextState extends State<AnimatedSummaryText> {
  int currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.text.isNotEmpty) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    final int totalLetters = widget.text.length;
    final int delayMs = widget.duration.inMilliseconds ~/ totalLetters;
    _timer = Timer.periodic(Duration(milliseconds: delayMs), (timer) {
      setState(() {
        currentIndex++;
      });
      if (currentIndex > totalLetters) {
        _timer?.cancel();
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedSummaryText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      currentIndex = 0;
      if (widget.text.isNotEmpty) {
        _startAnimation();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.auto_awesome, color: Color.fromARGB(255, 255, 230, 0)),
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
          Wrap(
            children: List.generate(widget.text.length, (index) {
              if (index < currentIndex) {
                return Text(
                  widget.text[index],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                );
              } else if (index == currentIndex &&
                  currentIndex <= widget.text.length) {
                return TweenAnimationBuilder<Offset>(
                  tween: Tween<Offset>(
                    begin: const Offset(-1.0, 0),
                    end: Offset.zero,
                  ),
                  duration: Duration(
                    milliseconds:
                        widget.duration.inMilliseconds ~/ widget.text.length,
                  ),
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: Offset(offset.dx * 20, 0),
                      child: child,
                    );
                  },
                  child: Text(
                    widget.text[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ),
        ],
      ),
    );
  }
}
