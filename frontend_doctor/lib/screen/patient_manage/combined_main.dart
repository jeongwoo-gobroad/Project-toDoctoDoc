import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_doc_for_doc/Database/chat_database.dart';
import 'package:to_doc_for_doc/controllers/chat_controller.dart';
import 'package:to_doc_for_doc/controllers/memo/memo_controller.dart';
import 'package:to_doc_for_doc/screen/chat/dm_list.dart';
import 'package:to_doc_for_doc/screen/patient_manage/memo_write.dart';
import 'package:to_doc_for_doc/screen/patient_manage/patient_manage_main.dart';


class CombinedTabs extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('채팅 및 환자 관리', style: TextStyle(fontWeight: FontWeight.bold),),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'DM'),
              Tab(text: '환자관리'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DMList(),
            PatientManageMain(),
          ],
        ),
      ),
    );
  }
}