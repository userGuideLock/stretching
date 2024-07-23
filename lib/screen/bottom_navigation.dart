import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_page.dart';
import 'diary_page.dart';
import 'survey_page copy 2.dart';

class BottomNavigationController extends GetxController {
  var currentIndex = 0;

  void changeTabIndex(int index) {
    currentIndex = index;
    update();
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
          body: IndexedStack(
            index: controller.currentIndex,
            children: const [
              HomePage(),
              DiaryPage(),
              SurveyPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex,
            onTap: controller.changeTabIndex,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: '다이어리',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.poll),
                label: '설문',
              ),
            ],
          ),
        );
      },
    );
  }
}
