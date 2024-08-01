import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/stress/stress_page4.dart';
import 'package:stretching/screen/survey/survey_page1.dart';

class StressViewController3 extends GetxController {
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

class StressPage3 extends StatelessWidget {
  const StressPage3({super.key});

  @override
  Widget build(BuildContext context) {
    // 이전 페이지에서 전달된 데이터 가져오기
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;
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
      body: GetBuilder<StressViewController3>(
        init: StressViewController3(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    '2/3 수면 관련',
                    style: TextStyle(
                      color: Color(0xff929292),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '오늘의 수면상태는 좋은편인가요?',
                    style: TextStyle(
                      color: Color(0xfff0f0f0),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildButton(controller, '최고의 잠을 잤다(1)'),
                  const SizedBox(height: 16),
                  _buildButton(controller, '딱 1시간만 더 자고 싶다(2)'),
                  const SizedBox(height: 16),
                  _buildButton(controller, '낮잠 자면 좋아질거 같다(3)'),
                  const SizedBox(height: 16),
                  _buildButton(controller, '하루종일 자고 싶다(4)'),
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
                                'step2': controller.selectedButton
                              };
                              Get.to(() => const StressPage4(),
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
          );
        },
      ),
    );
  }

  Widget _buildButton(StressViewController3 controller, String buttonLabel) {
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
