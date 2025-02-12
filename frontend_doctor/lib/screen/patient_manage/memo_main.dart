import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_controller.dart';

class MemoMain extends StatefulWidget {
  const MemoMain({super.key});

  @override
  State<MemoMain> createState() => _MemoMainState();
}

class _MemoMainState extends State<MemoMain> {
  MemoController memoController = Get.put(MemoController());

  @override
  void initState() {
    memoController.getMemoList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //메모 exists 불러오고
    //true면 list불러오기 호출, false면 메모없음.
    
    return const Placeholder();
  }
}