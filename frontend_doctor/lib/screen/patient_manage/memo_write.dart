import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_controller.dart';

class MemoWriteScreen extends StatefulWidget {
  const MemoWriteScreen({super.key , required this.patientId});
  final String patientId;

  @override
  _MemoWriteScreenState createState() => _MemoWriteScreenState();
}

class _MemoWriteScreenState extends State<MemoWriteScreen> {
  MemoController controller = Get.put(MemoController());
  int selectedColor = 0;
  final TextEditingController aiController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final ValueNotifier<int> characterCount = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    memoController.addListener(() {
      characterCount.value = memoController.text.length;
      if (characterCount.value > 500) {
        
      }
    });
  }

  @override
  void dispose() {
    aiController.dispose();
    memoController.dispose();
    detailsController.dispose();
    characterCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모하기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              print('AI text: ${aiController.text}');
              print('메모 내용: ${memoController.text}');
              print('세부사항: ${detailsController.text}');
              controller.writeMemo(widget.patientId, selectedColor, memoController.text, detailsController.text);
              
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
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
            const SizedBox(height: 20),
            
            TextField(
              controller: aiController,
              decoration: const InputDecoration(
                hintText: 'AI text...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Stack(
                children: [
                  TextField(
                    controller: memoController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: '메모를 입력하세요',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: ValueListenableBuilder<int>(
                      valueListenable: characterCount,
                      builder: (context, count, child) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$count자 / 500',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: detailsController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '세부사항을 입력하세요',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildColorButton(Color color, int index) {
    return GestureDetector(
      onTap: () {
        selectedColor = index;
        print('Color $index selected');
        
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
