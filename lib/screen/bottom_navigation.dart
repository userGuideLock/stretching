import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_page.dart';
import 'map_page.dart';
import 'record_page.dart';

class BottomNavigationController extends GetxController {
  var currentIndex = 0;

  void changeTabIndex(int index) {
    currentIndex = index;
    update(); // 상태 업데이트
  }
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomNavigationController>(
      init: BottomNavigationController(),
      builder: (controller) {
        return Scaffold(
          body: Navigator(
            pages: [
              if (controller.currentIndex == 0)
                const MaterialPage(child: HomePage()),
              if (controller.currentIndex == 1)
                const MaterialPage(child: RecordPage()),
              if (controller.currentIndex == 2)
                const MaterialPage(child: MapPage()),
            ],
            onPopPage: (route, result) => route.didPop(result),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex,
            onTap: (index) => controller.changeTabIndex(index),
            backgroundColor: Colors.black,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.poll),
                label: '기록',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: '지도',
              ),
            ],
          ),
        );
      },
    );
  }
}
