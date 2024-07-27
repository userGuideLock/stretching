import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/survey/survey_page4.dart';

class SurveyViewController22 extends GetxController {
  String selectedButton = ''; // 선택된 버튼

  // 버튼 선택
  void selectButton(String button) {
    if (selectedButton == button) {
      selectedButton = ''; // 이미 선택된 버튼 클릭 시 선택 해제
    } else {
      selectedButton = button; // 새로운 버튼 선택
    }
    update(); // 상태 업데이트
  }
}

class SurveyPage22 extends StatelessWidget {
  const SurveyPage22({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavigationController navController = Get.find();
    // 이전 페이지에서 전달된 데이터 가져오기
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;
    return GetBuilder<SurveyViewController22>(
      init: SurveyViewController22(), // 컨트롤러 초기화
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
                      '22/22. 일상 루틴',
                      style: TextStyle(
                        color: Color(0xff929292),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '지난 한달간 당신이 "잠잘 때" 시간, 장소, 상황을 인식하지 못하거나\n혼란스러워 함을 자주 했는지 물어보십시오.',
                      style: TextStyle(
                        color: Color(0xfff0f0f0),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const SizedBox(height: 16),
                    _buildButton(controller, '지난 한 달 동안 없었다.'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '한 주에 1번보다 적게'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '한 주에 1~2번 정도'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '한 주에 3번 이상'),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.selectedButton.isNotEmpty
                            ? () {
                                // 완료 버튼 클릭 시 동작 및 다음 페이지로 이동
                                final combinedData = {
                                  ...previousData,
                                  'step22': controller.selectedButton
                                };
                                navController.changeTabIndex(
                                    1); // MainMatePage로 이동하도록 설정

                                Get.to(() => const BottomNavigation(),
                                    arguments: combinedData);
                                print(combinedData);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.selectedButton.isNotEmpty
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

Widget _buildButton(SurveyViewController22 controller, String buttonLabel) {
  return GetBuilder<SurveyViewController22>(
    builder: (_) {
      return SizedBox(
        width: double.infinity,
        height: 105,
        child: ElevatedButton(
          onPressed: () {
            controller.selectButton(buttonLabel);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.selectedButton == buttonLabel
                ? const Color(0xff5956ff)
                : const Color(0xff4a4a4a),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          child: Text(
            buttonLabel,
            style: const TextStyle(
              color: Color(0xffd9d9d9),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    },
  );
}
