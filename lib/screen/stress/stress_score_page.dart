import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stretching/screen/bottom_navigation.dart';

class StressScoreViewController extends GetxController {}

class StressScorePage extends StatelessWidget {
  final int stressScore;
  final String userId;

  const StressScorePage(
      {super.key, required this.stressScore, required this.userId});

  @override
  Widget build(BuildContext context) {
    String stressLevel;
    String stressMessage;
    Color stressColor;

    if (stressScore <= 30) {
      stressLevel = '좋음';
      stressMessage = '스트레스가 거의 없습니다. 계속 이렇게 유지하세요!';
      stressColor = const Color(0xffacdcb4);
    } else if (stressScore <= 70) {
      stressLevel = '보통';
      stressMessage = '약간의 스트레스가 있습니다. 조심하세요!';
      stressColor = Colors.orange;
    } else {
      stressLevel = '나쁨';
      stressMessage = '스트레스가 많이 쌓였습니다. 휴식이 필요합니다!';
      stressColor = Colors.red;
    }

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
                  color: Colors.white,
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  '오늘의 스트레스 상태는',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      stressLevel,
                      style: TextStyle(
                        color: stressColor,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '이에요.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: stressScore / 100,
                      backgroundColor: Colors.grey[800],
                      color: stressColor,
                      minHeight: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '100/$stressScore',
                          style: TextStyle(
                            color: stressColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stressMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text(
                  '정확한 점수를 원하신다면',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '오늘의 기록을 작성하세요! \n또한 일상생활 속 건강데이터를 기록해주세요.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  "images/splash_page_star.png",
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 80,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xffacdcb4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () async {
                    final now = DateTime.now();
                    final formattedDate =
                        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                    final data = {
                      "userId": userId,
                      "date": formattedDate,
                      "score": stressScore,
                    };

                    final url = Uri.parse(
                        'https://hermi.danjam.site/api/v1/stress/record');
                    final headers = {'Content-Type': 'application/json'};
                    final body = json.encode(data);

                    try {
                      final response =
                          await http.post(url, headers: headers, body: body);
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        Get.snackbar(
                          'Success',
                          '스트레스 점수가 성공적으로 기록되었습니다.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                        Get.offAll(const BottomNavigation());
                      } else {
                        Get.snackbar(
                          'Error',
                          '스트레스 점수 기록에 실패했습니다: ${response.reasonPhrase}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        '스트레스 점수 기록 중 오류가 발생했습니다: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text(
                    '완료',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
