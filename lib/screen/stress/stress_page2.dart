import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/stress/stress_page3.dart';
import 'package:stretching/screen/survey/survey_page1.dart';

class StressViewController2 extends GetxController {
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

class StressPage2 extends StatelessWidget {
  const StressPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '스트레칭',
                style: TextStyle(
                  color: Color(0xffacdcb4),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Get.offAll(const BottomNavigation());
                },
              ),
            ],
          ),
        ),
      ),
      body: GetBuilder<StressViewController2>(
        init: StressViewController2(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    '1/3 심박수 관련',
                    style: TextStyle(
                      color: Color(0xff929292),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '오늘 감정을 주체할 수 없는 상황이 있었나요?',
                    style: TextStyle(
                      color: Color(0xfff0f0f0),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildButton(controller, '없음(1)'),
                  const SizedBox(height: 16),
                  _buildButton(controller, '3회 이내(2)'),
                  const SizedBox(height: 16),
                  _buildButton(controller, '3회 이상(3)'),
                  const SizedBox(height: 16),
                  _buildButton(controller, '알수없음(4)'),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.selectedButton.isNotEmpty
                          ? () {
                              Get.to(() => const StressPage3(), arguments: {
                                'step1': controller.selectedButton
                              });
                              print(controller.selectedButton);
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
          );
        },
      ),
    );
  }

  Widget _buildButton(StressViewController2 controller, String buttonLabel) {
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
  }
}
