import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/survey/survey_main_page.dart';
import 'package:stretching/screen/survey/survey_page.dart';

class SurveyResultPage extends StatelessWidget {
  final int score;

  const SurveyResultPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Widget buildMarker(bool condition) {
      return condition
          ? const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            )
          : const SizedBox.shrink();
    }

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
                Get.off(() => const SurveyMainPage());
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                '설문 조사 결과',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '100 / $score 점',
                style: const TextStyle(
                    color: Color(0xffacdcb4),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '하단 해석표를 확인해보세요',
                style: TextStyle(
                    color: Color(0xffacdcb4),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  buildMarker(score <= 20),
                  const SizedBox(width: 8),
                  const Text(
                    '0-20점: 매우 좋은 수면의 질',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '이 점수대는 수면의 질이 매우 우수함을 나타냅니다. 이 범위에 속하는 사람들은 일반적으로 충분한 수면 시간을 확보하고, 쉽게 잠들며, 잠을 유지하는 데 문제가 없습니다. 주간 졸림이나 피로가 거의 없으며, 수면에 방해가 되는 요인이 거의 없습니다. 전반적으로 건강한 수면 습관을 유지하고 있다고 볼 수 있습니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  buildMarker(score > 20 && score <= 40),
                  const SizedBox(width: 8),
                  const Text(
                    '21-40점: 좋은 수면의 질',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '이 점수대는 비교적 좋은 수면의 질을 나타냅니다. 약간의 수면 문제가 있을 수 있지만, 전반적으로 수면의 질은 양호합니다. 이러한 문제는 주기적으로 나타날 수 있으며, 대개 일시적이거나 경미한 문제들로 인해 발생합니다. 일상 생활에 큰 영향을 미치지는 않지만, 수면의 질을 조금 더 개선하려는 노력이 필요할 수 있습니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  buildMarker(score > 40 && score <= 60),
                  const SizedBox(width: 8),
                  const Text(
                    '41-60점: 중간 정도의 수면 문제',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '이 점수대는 중간 정도의 수면 문제를 나타냅니다. 수면의 질이 평균 이하로 떨어질 수 있으며, 잠들기 어려움, 중간에 자주 깨는 현상, 또는 충분한 수면을 취하지 못하는 등의 문제가 발생할 수 있습니다. 이러한 문제들은 일상 생활에 영향을 미칠 수 있으며, 피로감, 집중력 저하 등의 증상이 나타날 수 있습니다. 개선을 위한 노력이 필요할 수 있습니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  buildMarker(score > 60 && score <= 80),
                  const SizedBox(width: 8),
                  const Text(
                    '61-80점: 나쁜 수면의 질',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '이 점수대는 수면의 질이 나쁘다는 것을 의미합니다. 이 범위에 있는 사람들은 수면 장애나 지속적인 수면 문제를 경험할 가능성이 높습니다. 잠들기 어렵거나 잠을 유지하기 힘들고, 주간에 졸림이나 피로를 자주 느낄 수 있습니다. 이로 인해 일상적인 기능에 영향을 받을 수 있으며, 수면 개선을 위한 적극적인 조치가 필요할 수 있습니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  buildMarker(score > 80),
                  const SizedBox(width: 8),
                  const Text(
                    '81-100점: 매우 나쁜 수면의 질',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '이 점수대는 매우 나쁜 수면의 질을 나타냅니다. 심각한 수면 장애가 있을 가능성이 높으며, 이는 건강과 일상 생활에 큰 영향을 미칠 수 있습니다. 지속적인 불면증, 수면 유지의 어려움, 심한 주간 졸림, 또는 피로가 특징적입니다. 이 상태에서는 전문가의 평가와 치료가 필요할 수 있으며, 수면의 질을 향상시키기 위한 즉각적인 조치가 권장됩니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
