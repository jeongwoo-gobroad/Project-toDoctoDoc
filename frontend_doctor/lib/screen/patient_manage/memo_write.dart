import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // 길이 제한을 위한 inputFormatter 사용
import 'package:to_doc_for_doc/controllers/memo/memo_controller.dart';

import '../../model/color_list.dart';

class MemoWriteScreen extends StatefulWidget {
  const MemoWriteScreen({super.key, required this.patientId});
  final String patientId;

  @override
  _MemoWriteScreenState createState() => _MemoWriteScreenState();
}

class _MemoWriteScreenState extends State<MemoWriteScreen> {
  final MemoController controller = Get.put(MemoController());
  int selectedColor = 0;
  final TextEditingController memoController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final ValueNotifier<int> characterCount = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    memoController.addListener(() {
      characterCount.value = memoController.text.length;
    });
  }
  @override
  void dispose() {
    memoController.dispose();
    detailsController.dispose();
    characterCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '메모 작성',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        for (final i in ColorType.values) ... [
                          if (i.num != 7) ... [
                            _buildColorButton(i)
                          ]
                        ],


/*                        _buildColorButton(Colors.red, 0),
                        _buildColorButton(Colors.orange, 1),
                        _buildColorButton(Colors.yellow, 2),
                        _buildColorButton(Colors.green, 3),
                        _buildColorButton(Colors.blue, 4),
                        _buildColorButton(Colors.purple, 5),
                        _buildColorButton(Colors.brown, 6),*/
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
                child: Stack(
                  children: [
                    TextFormField(
                      controller: memoController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(500),
                      ],
                      decoration: const InputDecoration(
                        hintText: '메모를 입력하세요 (최대 500자)',
                        contentPadding: EdgeInsets.all(16),
                        border: InputBorder.none, // 기본 테두리 제거
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: ValueListenableBuilder<int>(
                        valueListenable: characterCount,
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
                    TextFormField(
                      controller: detailsController,
                      maxLines: 3,
                      decoration:  const InputDecoration(
      hintText: '세부사항을 입력하세요',
      contentPadding: EdgeInsets.all(16),
      border: InputBorder.none, // 기본 TextField 테두리 제거
                    ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.writeMemo(
                    widget.patientId,
                    selectedColor,
                    memoController.text,
                    detailsController.text,
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 225, 234, 205),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '제출',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(ColorType color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color.num;
        });
        print('Color ${color.num} selected');
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.color,
          shape: BoxShape.circle,
          border: selectedColor == color.num
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }
}
