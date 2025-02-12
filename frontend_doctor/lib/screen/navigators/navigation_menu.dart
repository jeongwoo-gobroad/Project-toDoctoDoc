import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/screen/curate/curate_screen.dart';
import 'package:to_doc_for_doc/screen/home.dart';
import 'package:to_doc_for_doc/screen/patient_manage/combined_main.dart';
import 'package:to_doc_for_doc/screen/patient_manage/memo_main.dart';
import 'package:to_doc_for_doc/screen/patient_manage/memo_write.dart';
import 'package:to_doc_for_doc/screen/patient_manage/patient_manage_main.dart';

import '../chat/dm_list.dart';
import '../profile_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
        ()=> NavigationBar(
          height: 60,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,  
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home), label: '홈'),
            const NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'DM'),
            const NavigationDestination(icon: Icon(Icons.manage_accounts), label: '환자관리'),
            const NavigationDestination(icon: Icon(Icons.fact_check), label: '큐레이팅'),
            const NavigationDestination(icon: Icon(Icons.person_2_outlined), label: '프로필'),
          ],
        ),
      ),
      body: Obx(()=> controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs; //home 상태관리

  final screens = [Home(), DMList(), CombinedTabs(), CurateScreen() , DoctorProfileView()];

}