import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/controllers/query_controller.dart';
import 'package:to_doc/screens/result_edit.dart';

class Airesult extends StatefulWidget {

  Airesult({super.key, required this.title});
  final String title;

  @override
  State<Airesult> createState() => _AiresultState();
}

class _AiresultState extends State<Airesult> {
  final QueryController queryController = Get.put(QueryController());
  bool isAnimationComplete = false;
 @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (queryController.isLimited.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showQueryLimitDialog(context);
      });
    }
      if (queryController.isLoading.value) {
        // 로딩 상태일 때
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('답변 생성 중...'),
          ),
          body: Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(minHeight: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                BlinkingCursor(),
              //   Row(
                  
                
              //   children: const [
              //     Text(
              //       "답변 생성 중",
              //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //     ),
              //     SizedBox(width: 8),
              //     BlinkingCursor(),
              //   ],
              // ),
                
              ],
            ),
          ),
        ),
      ),
    ),
        );
      } else {
        // 정상 상태일 때
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('공유하기'),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.black, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          queryController.title.value,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        queryController.context.value.isNotEmpty
                              ? AnimatedSummaryText(
                                  text: queryController.context.value,
                                  onAnimationComplete: () {setState(() {
                                    isAnimationComplete = true;
                                  });},
                                  wrapWithContainer: false,
                                )
                              : const SizedBox(),
                          const SizedBox(height: 25),
                          if(isAnimationComplete)
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 10),
                                backgroundColor: Color.fromARGB(255, 225, 234, 205),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                              ),
                              onPressed: () {
                                Get.to(() => ResultEdit());
                              },
                              child: const Text(
                                '내가 걱정을 이겨낸 방법을 공유하기',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                                ),
                ),
            ),
          ),
          ),
        );
      }
    });
  }

  void _showQueryLimitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('쿼리 사용 제한'),
        content: Text('오늘 사용 가능한 쿼리 횟수를 모두 사용했습니다.'),
        actions: <Widget>[
          TextButton(
            child: Text('확인'),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      );
    },
  );
}
}
class BlinkingCursor extends StatefulWidget {
  const BlinkingCursor({Key? key}) : super(key: key);

  @override
  _BlinkingCursorState createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: const Text(
        '▊',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
class AnimatedSummaryText extends StatefulWidget {
  final String text;
  final Duration duration;
  final VoidCallback? onAnimationComplete;
  final bool wrapWithContainer;

  const AnimatedSummaryText({
    Key? key,
    required this.text,
    this.duration = const Duration(milliseconds: 1500),
    this.onAnimationComplete,
    this.wrapWithContainer = true,
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
    return LayoutBuilder(
      builder: (context, constraints){

    Widget animatedText = Wrap(
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
        } else if (index == currentIndex && currentIndex <= widget.text.length) {
          return TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(
              begin: const Offset(-1.0, 0),
              end: Offset.zero,
            ),
            duration: Duration(
              milliseconds: widget.duration.inMilliseconds ~/ widget.text.length,
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
    );

    if (widget.wrapWithContainer) {
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
            animatedText,
          ],
        ),
      );
    } else {
       return Container(
          width: double.infinity,
          child: animatedText,
        );
    }
  }
    );
  }
    
}












