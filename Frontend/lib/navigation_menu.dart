import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:to_doc/aboutpage.dart';
import 'package:to_doc/ai_chat_main.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/home.dart';
import 'package:to_doc/navigator/side_menu.dart';
import 'package:to_doc/screens/careplus/curate.dart';
import 'package:to_doc/screens/careplus/curate_feed.dart';
import 'package:to_doc/screens/careplus/curate_home.dart';
import 'package:to_doc/screens/graph_test.dart';
import 'package:to_doc/screens/map_screen.dart';
import 'package:to_doc/screens/graph_board.dart';

class NavigationMenu extends StatelessWidget {
  DateTime? currentBackPressTime;
  UserinfoController userController = Get.find<UserinfoController>();
  NavigationMenu({super.key});
  

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Get.snackbar('알림', '종료하시려면 뒤로가기를 한번 더 눌러주세요.',
              snackPosition: SnackPosition.BOTTOM);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        drawer: Obx(() => SideMenu(
          userController.usernick.value,
          userController.email.value
        )),
        appBar: AppBar(
          centerTitle: true,
          title: InkWell(
            onTap: () {
              Get.to(() => Aboutpage());
            },
            child: Text('토닥toDoc',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          ),
        ),
        bottomNavigationBar: Obx(
          () => NavigationBar(
            height: 60,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            destinations: [
              const NavigationDestination(icon: Icon(Icons.home), label: '홈'),
              const NavigationDestination(icon: Icon(Icons.chat), label: '챗봇'),
              const NavigationDestination(
                  icon: Icon(Icons.analytics), label: '그래프보드'),
              const NavigationDestination(
                  icon: Icon(Icons.place), label: '마음병원'),
              const NavigationDestination(
                  icon: Icon(Icons.fact_check), label: '큐레이팅'),
            ],
          ),
        ),
        body: Obx(() => controller.screens[controller.selectedIndex.value]),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs; //home 상태관리

  final screens = [
    Home(),
    AichatMain(),
    TagGraphBoard(),
    MapAndListScreen(),
    CurationHomeScreen()
  ];
}
