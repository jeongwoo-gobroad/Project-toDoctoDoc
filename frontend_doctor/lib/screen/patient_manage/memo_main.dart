import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_controller.dart';
import 'package:to_doc_for_doc/screen/patient_manage/memo_detail.dart';

import '../../model/color_list.dart';

class MemoMain extends StatefulWidget {
  const MemoMain({super.key});

  @override
  State<MemoMain> createState() => _MemoMainState();
}

class _MemoMainState extends State<MemoMain> {
  final MemoController memoController = Get.put(MemoController());
/*  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.green;
      case 4:
        return Colors.blue;
      case 5:
        return Colors.purple;
      case 6:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모 목록'),
      ),
      body: Obx(() {
        if (memoController.memoLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if(memoController.memoList.isEmpty){
          return const Center(child: Text('메모 없음'));
        }
        return Obx(()=>
          ListView.builder(
            itemCount: memoController.memoList.length,
            itemBuilder: (context, index) {
              final memo = memoController.memoList[index];
              final formattedDate = DateFormat('MM/dd HH:mm').format(memo.updatedAt.toLocal());
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                   leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorType.getByCode(memo.color).color,
                    ),
                  ),
                  title: Text('유저: ${memo.user.usernick}'), 
                  subtitle: Text('수정 시각: ${formattedDate}'),
                   trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'delete') {
                      bool confirmed = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('삭제 확인'),
                          content: const Text('정말로 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed) {
                        
                        bool deleted = await memoController.deleteMemo(memo.id);
                        if(deleted){
                          Get.snackbar('삭제', '메모가 삭제되었습니다.');

                        }
                        else{
                          Get.snackbar('실패', '메모 삭제 실패.');
                        }
                        
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('삭제'),
                    ),
                  ],
                ),
                  onTap: ()async{
                    print(memo.id);
                    await memoController.getMemoDetail(memo.id);
                    Get.to(()=> MemoDetailScreen(patientId: memo.id, selectedColor: memo.color,));
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
