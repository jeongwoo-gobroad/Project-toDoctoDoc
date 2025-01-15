import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc_for_doc/src/curate/curate_detail_screen.dart';
import 'package:to_doc_for_doc/src/curate_screen.dart';
import 'package:to_doc_for_doc/src/home.dart';
import 'package:to_doc_for_doc/src/test_screen.dart';


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
            const NavigationDestination(icon: Icon(Icons.fact_check), label: '큐레이팅'),
            const NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
        
          ],
        ),
      ),
      body: Obx(()=> controller.screens[controller.selectedIndex.value]),



    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs; //home 상태관리

  final screens = [Home(), TestScreen(), CurateScreen() , CurateDetailScreen()]; 

}