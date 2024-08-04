import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stretching/screen/bottom_navigation.dart';

class StressScoreLogPage extends StatelessWidget {
  final List<dynamic> stressScores;

  const StressScoreLogPage({super.key, required this.stressScores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
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
          children: [
            const SizedBox(height: 50),
            Expanded(
              // ListView.builder가 확장되도록 설정
              child: ListView.builder(
                itemCount: stressScores.length,
                itemBuilder: (context, index) {
                  final stressScore = stressScores[index];
                  return Card(
                    color: const Color(0xFF424242),
                    child: ListTile(
                      title: Text(
                        stressScore['date'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '점수: ${stressScore['score']}',
                        style: const TextStyle(color: Colors.grey),
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
