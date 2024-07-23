import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';

class SurveyViewController3 extends GetxController {
  String hobby = ''; // 입력된 취미

  void updateHobby(String value) {
    hobby = value;
    update();
  }
}

class SurveyPage3 extends StatelessWidget {
  const SurveyPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavigationController navController = Get.find();
    // 이전 페이지에서 전달된 데이터 가져오기
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;
    return GetBuilder<SurveyViewController3>(
      init: SurveyViewController3(), // 컨트롤러 초기화
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false, // 기본 뒤로 가기 버튼 제거
            title: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '스트레칭',
                    style: TextStyle(
                      color: Color(0xffacdcb4),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(Icons.close),
                  color: const Color.fromARGB(255, 255, 255, 255),
                  onPressed: () {
                    navController.changeTabIndex(1); // MainMatePage로 이동하도록 설정
                    Get.to(() => const BottomNavigation());
                  },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      '1/20. 일상 루틴',
                      style: TextStyle(
                        color: Color(0xff929292),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '당신의 취미는?',
                      style: TextStyle(
                        color: Color(0xfff0f0f0),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xff4a4a4a),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        onChanged: controller.updateHobby,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: '취미를 입력해주세요.',
                          hintStyle: TextStyle(color: Color(0xff929292)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.hobby.isNotEmpty
                            ? () {
                                // 다음 페이지로 이동하는 로직 추가
                                print(controller.hobby);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.hobby.isNotEmpty
                              ? const Color(0xffbbffba)
                              : const Color(0xff4a4a4a),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        child: const Text(
                          '다음',
                          style: TextStyle(
                            color: Color(0xff282828),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
