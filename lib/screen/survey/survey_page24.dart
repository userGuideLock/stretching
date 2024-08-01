import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/survey/%08survey_result_page.dart';

class SurveyViewController24 extends GetxController {
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

  int calculateScore(Map<String, dynamic> data) {
    int score = 0;

    Map<String, int> step1To10Scores = {
      '전혀없음': 0,
      '거의없음': 1,
      '때때로 있음': 2,
      '자주있음': 3,
      '매우자주': 4
    };

    Map<String, int> step11To24Scores = {
      '지난 한달 동안 없었다 (없다)': 0,
      '한 주에 1번보다 적게(주 1회미만)': 1,
      '한 주에 1~2번 정도(주 1~2회)': 2,
      '한 주에 3번 이상(주 3회 이상)': 3
    };

    Map<String, int> step21Scores = {
      '매우좋음': 0,
      '상당히 좋음': 1,
      '상당히 나쁨': 2,
      '매우 나쁨': 3
    };

    // Step 1 to 10 score calculation
    int step1To10Total = 0;
    for (int i = 1; i <= 10; i++) {
      step1To10Total += step1To10Scores[data['step$i']] ?? 0;
    }

    // Step 11 to 20 score calculation
    int step11To20Total = 0;
    for (int i = 11; i <= 20; i++) {
      step11To20Total += step11To24Scores[data['step$i']] ?? 0;
    }

    int step11To20Score;
    if (step11To20Total == 0) {
      step11To20Score = 0;
    } else if (step11To20Total <= 10) {
      step11To20Score = 10;
    } else if (step11To20Total <= 20) {
      step11To20Score = 20;
    } else {
      step11To20Score = 30;
    }

    // Step 21 to 24 score calculation
    int step21To24Total = 0;
    for (int i = 21; i <= 24; i++) {
      step21To24Total += step21Scores[data['step$i']] ?? 0;
    }

    int step21To24Score;
    if (step21To24Total == 0) {
      step21To24Score = 0;
    } else if (step21To24Total <= 2) {
      step21To24Score = 10;
    } else if (step21To24Total <= 4) {
      step21To24Score = 20;
    } else {
      step21To24Score = 30;
    }

    // Combine all scores to make the final score
    score = step1To10Total + step11To20Score + step21To24Score;

    return score;
  }
}

class SurveyPage24 extends StatelessWidget {
  const SurveyPage24({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavigationController navController = Get.find();
    // 이전 페이지에서 전달된 데이터 가져오기
    final Map<String, dynamic> previousData =
        Get.arguments as Map<String, dynamic>;
    return GetBuilder<SurveyViewController24>(
      init: SurveyViewController24(), // 컨트롤러 초기화
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
                      '14/14. 수면 스트레스',
                      style: TextStyle(
                        color: Color(0xff929292),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '지난 한달 동안, 당신은 일에 열중하는데 얼마나 많은 문제가 있었습니까?',
                      style: TextStyle(
                        color: Color(0xfff0f0f0),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildButton(controller, '지난 한달 동안 없었다 (없다)'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '한 주에 1번보다 적게(주 1회미만)'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '한 주에 1~2번 정도(주 1~2회)'),
                    const SizedBox(height: 16),
                    _buildButton(controller, '한 주에 3번 이상(주 3회 이상)'),
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
                                  'step24': controller.selectedButton
                                };

                                int score =
                                    controller.calculateScore(combinedData);

                                Get.to(() => SurveyResultPage(score: score),
                                    arguments: combinedData);
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

Widget _buildButton(SurveyViewController24 controller, String buttonLabel) {
  return GetBuilder<SurveyViewController24>(
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
