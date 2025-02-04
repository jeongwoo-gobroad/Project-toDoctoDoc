import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:to_doc/screens/aichat/ai_chat_main.dart';
import 'package:to_doc/controllers/userInfo_controller.dart';
import 'package:to_doc/home.dart';
import 'package:to_doc/navigator/side_menu.dart';
import 'package:to_doc/screens/careplus/curate_main.dart';
import 'package:to_doc/screens/hospital/map_screen.dart';
import 'package:to_doc/screens/graph_board.dart';

class NavigationMenu extends StatelessWidget {
  DateTime? currentBackPressTime;
  int startScreen;
  UserinfoController userController = Get.find<UserinfoController>();
  NavigationMenu({super.key, required this.startScreen});


  @override
  Widget build(BuildContext context) {
    print('test nav');

    final controller = Get.put(NavigationController());

    if (startScreen != 0) {
      controller.setIndex(startScreen);
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        //기존코드드
        // DateTime now = DateTime.now();
        // if (currentBackPressTime == null ||
        //     now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
        //   currentBackPressTime = now;
        //   Get.snackbar('알림', '종료하시려면 뒤로가기를 한번 더 눌러주세요.',
        //       snackPosition: SnackPosition.BOTTOM);
        // } else {
        //   SystemNavigator.pop();
        // }

        //alertdialog 기반 (안될시 위코드로 변경)
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('알림'),
                content: Text('종료하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text('예'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('아니오'),
                  ),
                ],
              );
            },
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        drawer: Obx(() => SideMenu(
            userController.usernick.value, userController.email.value)),
        bottomNavigationBar: Obx(
              () => NavigationBar(
            height: 60,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
            controller.selectedIndex.value = index,
            destinations: [
              const NavigationDestination(icon: Icon(Icons.home), label: '홈'),
              const NavigationDestination(icon: Icon(Icons.chat), label: 'AI 채팅'),
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

  void setIndex(int index) {
    selectedIndex.value = index;
  }



  final screens = [
    Home(),
    AichatMain(),
    GraphBoard(),
    MapAndListScreen(),
    CurateMain()
  ];
}
