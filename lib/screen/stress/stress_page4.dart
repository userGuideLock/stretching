// stressPage4.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/stress/stress_score_page.dart';

class StressViewController4 extends GetxController {
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

class StressPage4 extends StatelessWidget {
  const StressPage4({super.key});

  int calculateHeartRateScore(String step1) {
    switch (step1) {
      case '없음(1)':
        return 5;
      case '3회 이내(2)':
        return 15;
      case '3회 이상(3)':
        return 30;
      case '알수없음(4)':
        return 20;
      default:
        return 0;
    }
  }

  int calculateSleepScore(String step2) {
    switch (step2) {
      case '최고의 잠을 잤다(1)':
        return 5;
      case '딱 1시간만 더 자고 싶다(2)':
        return 10;
      case '낮잠 자면 좋아질거 같다(3)':
        return 15;
      case '하루종일 자고 싶다(4)':
        return 20;
      default:
        return 0;
    }
  }

  int calculateRespiratoryRateScore(String step3) {
    switch (step3) {
      case '없다(1)':
        return 0;
      case '한번(2)':
        return 15;
      case '두번(3)':
        return 25;
      case '셀수없음(4)':
        return 30;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: GetBuilder<StressViewController4>(
        init: StressViewController4(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    '3/3 호흡 관련',
                    style: TextStyle(
                      color: Color(0xff929292),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '오늘 숨을 쉬기 힘든 순간이 있으셨나요?',
                    style: TextStyle(
                      color: Color(0xfff0f0f0),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildButton(controller, '없다(1)'),
                  const SizedBox(height: 16),
                  _buildButton(controller, '한번(2)'),
                  const SizedBox(height: 16),
                  _buildButton(controller, '두번(3)'),
                  const SizedBox(height: 16),
                  _buildButton(controller, '셀수없음(4)'),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.selectedButton.isNotEmpty
                          ? () {
                              final combinedData = {
                                ...previousData,
                                'step3': controller.selectedButton
                              };

                              int step1Score = calculateHeartRateScore(
                                  combinedData['step1']);
                              int step2Score =
                                  calculateSleepScore(combinedData['step2']);
                              int step3Score = calculateRespiratoryRateScore(
                                  combinedData['step3']);
                              int stressScore =
                                  step1Score + step2Score + step3Score;

                              Get.to(
                                () => StressScorePage(stressScore: stressScore),
                                arguments: combinedData,
                              );
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

  Widget _buildButton(StressViewController4 controller, String buttonLabel) {
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
