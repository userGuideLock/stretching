import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/diary/diary_entry_page2.dart';
import 'package:stretching/screen/register/register_page3.dart';
import 'package:stretching/screen/register/register_page4.dart';
import 'package:stretching/screen/register_page.dart';
import 'package:stretching/screen/splash_page.dart';
import 'package:stretching/screen/survey/survey_page3.dart';

class RegisterViewController4 extends GetxController {
  final selectedButtons = <String>[];

  // 버튼 선택/해제
  void selectButton(String button) {
    if (selectedButtons.contains(button)) {
      selectedButtons.remove(button); // 이미 선택된 버튼 클릭 시 선택 해제
    } else {
      if (selectedButtons.length < 4) {
        selectedButtons.add(button); // 4개 미만인 경우 새로운 버튼 선택
      }
    }
    update(); // 상태 업데이트
  }

  bool get isButtonLimitReached => selectedButtons.length == 4;
}

class RegisterPage4 extends StatelessWidget {
  const RegisterPage4({super.key});

  @override
  Widget build(BuildContext context) {
    // 이전 페이지에서 전달된 데이터 가져오기
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;

    return GetBuilder<RegisterViewController4>(
      init: RegisterViewController4(), // 컨트롤러 초기화
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
                    Get.to(() => const SplashPage());
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
                      '4/4 회원가입',
                      style: TextStyle(
                        color: Color(0xff929292),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '어떤 방식으로 \n스트레스를 해소하나요?',
                      style: TextStyle(
                        color: Color(0xfff0f0f0),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildButton(controller, '운동'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '명상'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '독서'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '음악감상'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '산책'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '요가'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '친구'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '영화'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '수면'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '요리'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '여행'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '미술활동'),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: GetBuilder<RegisterViewController4>(
                        builder: (controller) {
                          return ElevatedButton(
                            onPressed: controller.isButtonLimitReached
                                ? () {
                                    // 완료 버튼 클릭 시 동작 및 다음 페이지로 이동
                                    final combinedData = {
                                      ...previousData,
                                      'stepFour': controller.selectedButtons
                                    };
                                    Get.to(() => const RegisterPage(),
                                        arguments: combinedData);
                                    print(combinedData);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: controller.isButtonLimitReached
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
                          );
                        },
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

  Widget _buildButton(RegisterViewController4 controller, String buttonLabel) {
    return GetBuilder<RegisterViewController4>(
      builder: (_) {
        return SizedBox(
          width: double.infinity,
          height: 105,
          child: ElevatedButton(
            onPressed: () {
              controller.selectButton(buttonLabel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.selectedButtons.contains(buttonLabel)
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
}
