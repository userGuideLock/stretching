import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';

class SurveyResultPage extends StatelessWidget {
  final int score;

  const SurveyResultPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> combinedData =
        Get.arguments as Map<String, dynamic>;

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
                Get.off(() => const BottomNavigation());
              },
            ),
          ),
        ],
      ),
      body: Padding(
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
              '총 점수: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: combinedData.length,
                itemBuilder: (context, index) {
                  String key = combinedData.keys.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '$key: ${combinedData[key]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
