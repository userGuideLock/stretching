import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/diary/diary_entry_page2.dart';
import 'package:stretching/screen/register/register_page3.dart';
import 'package:stretching/screen/splash_page.dart';
import 'package:stretching/screen/survey/survey_page3.dart';

class RegisterViewController2 extends GetxController {
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

class RegisterPage2 extends StatelessWidget {
  const RegisterPage2({super.key});

  @override
  Widget build(BuildContext context) {
    // 이전 페이지에서 전달된 데이터 가져오기
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;

    return GetBuilder<RegisterViewController2>(
      init: RegisterViewController2(), // 컨트롤러 초기화
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
                      '2/4 회원가입',
                      style: TextStyle(
                        color: Color(0xff929292),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '당신의 직종은?',
                      style: TextStyle(
                        color: Color(0xfff0f0f0),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildButton(controller, '사무직'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '서비스직'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '감정노동'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '생산 • 제조업'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '사회서비스'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '여러 직종 혼합'),
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
                                  'stepTwo': controller.selectedButton
                                };
                                Get.to(() => const RegisterPage3(),
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

  Widget _buildButton(RegisterViewController2 controller, String buttonLabel) {
    return GetBuilder<RegisterViewController2>(
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
}
