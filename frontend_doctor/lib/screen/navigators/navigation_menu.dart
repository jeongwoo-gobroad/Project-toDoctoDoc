import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/screen/curate/curate_screen.dart';
import 'package:to_doc_for_doc/screen/home.dart';
import 'package:to_doc_for_doc/screen/patient_manage/combined_main.dart';

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
            const NavigationDestination(icon: Icon(Icons.home),
            selectedIcon: Icon(Icons.home, color: Color.fromARGB(255, 164, 199, 81),), label: '홈'),
            const NavigationDestination(icon: Icon(Icons.manage_accounts), 
            selectedIcon: Icon(Icons.manage_accounts, color: Color.fromARGB(255, 164, 199, 81),), label: '환자관리'),
            const NavigationDestination(icon: Icon(Icons.fact_check),
            selectedIcon: Icon(Icons.fact_check, color: Color.fromARGB(255, 164, 199, 81),), label: '큐레이팅'),
            const NavigationDestination(icon: Icon(Icons.person_2_outlined),
            selectedIcon: Icon(Icons.person_2_outlined, color: Color.fromARGB(255, 164, 199, 81),), label: '프로필'),
          ],
        ),
      ),
      body: Obx(()=> controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs; //home 상태관리

  final screens = [Home(), CombinedTabs(), CurateScreen() , DoctorProfileView()];

}