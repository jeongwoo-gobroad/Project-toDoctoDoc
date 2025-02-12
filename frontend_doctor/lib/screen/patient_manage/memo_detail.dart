import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
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

  // 텍스트 컨트롤러들
  final TextEditingController memoTextController = TextEditingController();
  final TextEditingController detailsTextController = TextEditingController();

  // 메모 필드의 글자수를 실시간으로 관리하는 ValueNotifier
  final ValueNotifier<int> memoCharCount = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    
      //print(memoController.memoDetail.value!.memo);
      
      memoTextController.text = controller.memoDetail.value!.memo;
      detailsTextController.text = controller.memoDetail.value!.details;
      
    

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
      body: Obx(() {
        if (controller.detailLoading.value == true) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('--------------------Ai 부분----------------------'),
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
                      // 카운터와 업데이트 버튼을 Row로 배치
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async{
                            final updatedDetails = detailsTextController.text;
                            bool result = await controller.editDetails(
                                  widget.patientId,
                                  updatedDetails,
                                );
                                if(result){
                                  Get.snackbar('성공', '세부사항이 업데이트 되었습니다.');
                                } else{
                                  Get.snackbar('실패', '세부사항을 업데이트 하지 못했습니다.');
                                }
                          },
                          child: const Text('세부사항 업데이트'),
                        ),
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
        // 필요시 색상 업데이트 메서드 호출 가능 (예: controller.updateColor(...))
        print('Color $index selected');
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
