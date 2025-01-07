import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_doc/home.dart';

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
            const NavigationDestination(icon: Icon(Icons.chat), label: '챗봇'),
            const NavigationDestination(icon: Icon(Icons.analytics), label: '그래프보드'),
            const NavigationDestination(icon: Icon(Icons.place), label: '마음병원'),
            const NavigationDestination(icon: Icon(Icons.fact_check), label: '큐레이팅'),
        
          ],
        ),
      ),
      body: Obx(()=> controller.screens[controller.selectedIndex.value]),



    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs; //home 상태관리

  final screens = [Home(), , Container(color: Colors.red), Container(color: Colors.blue), Container(color: Colors.purple)];

}