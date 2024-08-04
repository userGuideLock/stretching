import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/stress/stress_score_page.dart';

class StressViewController1 extends GetxController {
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int currentMessageIndex = 0;

  final List<String> loadingMessages = [
    '데이터를 수집하고 있습니다...',
    '심박수를 확인하고 있습니다...',
    '수면 데이터를 분석하고 있습니다...',
    '스트레스 점수를 계산하고 있습니다...'
  ];

  int totalSteps;
  int totalSleepMinutes;
  int asleepMinutes;
  int awakeMinutes;
  int deepSleepMinutes;
  int lightSleepMinutes;
  int remSleepMinutes;
  double averageHeartRate;
  double respiratoryRate;

  StressViewController1({
    required this.totalSteps,
    required this.totalSleepMinutes,
    required this.asleepMinutes,
    required this.awakeMinutes,
    required this.deepSleepMinutes,
    required this.lightSleepMinutes,
    required this.remSleepMinutes,
    required this.averageHeartRate,
    required this.respiratoryRate,
  });

  @override
  void onInit() {
    super.onInit();
    startLoading();
  }

  void startLoading() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (currentMessageIndex < loadingMessages.length - 1) {
        currentMessageIndex++;
        update();
      } else {
        timer.cancel();
        isLoading = false;
        hasError = _hasSignificantZeroData();
        update();
        if (!hasError) {
          Get.off(() => StressScorePage(
                stressScore: calculateTotalScore(),
                userId: userId ?? '',
              ));
        }
      }
    });
  }

  bool _hasSignificantZeroData() {
    int zeroCount = 0;
    List<double> dataValues = [
      totalSteps.toDouble(),
      totalSleepMinutes.toDouble(),
      asleepMinutes.toDouble(),
      awakeMinutes.toDouble(),
      deepSleepMinutes.toDouble(),
      lightSleepMinutes.toDouble(),
      remSleepMinutes.toDouble(),
      averageHeartRate,
      respiratoryRate
    ];

    zeroCount = dataValues.where((value) => value == 0).length;

    return zeroCount >= (dataValues.length / 2);
  }

  int calculateTotalScore() {
    int sleepScore = calculateSleepScore();
    double deepSleepPercentage = totalSleepMinutes == 0
        ? 0
        : (deepSleepMinutes / totalSleepMinutes) * 100;
    double remSleepPercentage = totalSleepMinutes == 0
        ? 0
        : (remSleepMinutes / totalSleepMinutes) * 100;
    double lightSleepPercentage = totalSleepMinutes == 0
        ? 0
        : (lightSleepMinutes / totalSleepMinutes) * 100;

    int deepSleepScore =
        calculateSleepStageScore(deepSleepMinutes, deepSleepPercentage);
    int remSleepScore =
        calculateSleepStageScore(remSleepMinutes, remSleepPercentage);
    int lightSleepScore =
        calculateSleepStageScore(lightSleepMinutes, lightSleepPercentage);

    int sleepAwakeScore = calculateSleepAwakeScore();
    int heartRateScore = calculateHeartRateScore();
    int respiratoryRateScore = calculateRespiratoryRateScore();

    return sleepScore +
        deepSleepScore +
        remSleepScore +
        lightSleepScore +
        sleepAwakeScore +
        heartRateScore +
        respiratoryRateScore;
  }

  int calculateSleepScore() {
    if (totalSleepMinutes == 0) return 5;
    if (totalSleepHours >= 7 && totalSleepHours <= 9) {
      return 5;
    } else if ((totalSleepHours >= 6 && totalSleepHours < 7) ||
        (totalSleepHours > 9 && totalSleepHours <= 10)) {
      return 10;
    } else if ((totalSleepHours >= 5 && totalSleepHours < 6) ||
        (totalSleepHours > 10 && totalSleepHours <= 11)) {
      return 15;
    } else {
      return 20;
    }
  }

  int calculateSleepStageScore(int stageMinutes, double percentage) {
    if (stageMinutes == 0) return 5;
    if (percentage >= 20 && percentage <= 25) {
      return 0;
    } else if ((percentage >= 15 && percentage < 20) ||
        (percentage > 25 && percentage <= 30)) {
      return 2;
    } else if ((percentage >= 10 && percentage < 15) ||
        (percentage > 30 && percentage <= 35)) {
      return 4;
    } else {
      return 6;
    }
  }

  int calculateSleepAwakeScore() {
    if (awakeMinutes == 0) return 5;
    if (awakeMinutes <= 10) {
      return 0;
    } else if (awakeMinutes <= 20) {
      return 10;
    } else {
      return 20;
    }
  }

  int calculateHeartRateScore() {
    if (averageHeartRate == 0) return 10;
    if (averageHeartRate >= 40 && averageHeartRate <= 60) {
      return 0;
    } else if (averageHeartRate > 60 && averageHeartRate <= 70) {
      return 10;
    } else if ((averageHeartRate > 70) || (averageHeartRate < 40)) {
      return 15;
    } else {
      return 20;
    }
  }

  int calculateRespiratoryRateScore() {
    if (respiratoryRate == 0) return 0;
    if (respiratoryRate >= 12 && respiratoryRate <= 20) {
      return 0;
    } else if (respiratoryRate > 20 && respiratoryRate <= 24) {
      return 10;
    } else if (respiratoryRate > 24 || respiratoryRate < 12) {
      return 15;
    } else {
      return 20;
    }
  }

  double get totalSleepHours => totalSleepMinutes / 60;
}

class StressPage1 extends StatelessWidget {
  final int totalSteps;
  final int totalSleepMinutes;
  final int asleepMinutes;
  final int awakeMinutes;
  final int deepSleepMinutes;
  final int lightSleepMinutes;
  final int remSleepMinutes;
  final double averageHeartRate;
  final double respiratoryRate;

  const StressPage1({
    super.key,
    required this.totalSteps,
    required this.totalSleepMinutes,
    required this.asleepMinutes,
    required this.awakeMinutes,
    required this.deepSleepMinutes,
    required this.lightSleepMinutes,
    required this.remSleepMinutes,
    required this.averageHeartRate,
    required this.respiratoryRate,
  });

  @override
  Widget build(BuildContext context) {
    final StressViewController1 controller = Get.put(
      StressViewController1(
        totalSteps: totalSteps,
        totalSleepMinutes: totalSleepMinutes,
        asleepMinutes: asleepMinutes,
        awakeMinutes: awakeMinutes,
        deepSleepMinutes: deepSleepMinutes,
        lightSleepMinutes: lightSleepMinutes,
        remSleepMinutes: remSleepMinutes,
        averageHeartRate: averageHeartRate,
        respiratoryRate: respiratoryRate,
      ),
    );

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
      body: GetBuilder<StressViewController1>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    controller.loadingMessages[controller.currentMessageIndex],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (controller.hasError) {
            return const Center(
              child: Text(
                '점수에 필요한 데이터가 부족합니다.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    '오늘의 스트레스 점수는',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    '스트레스 점수: ${controller.calculateTotalScore()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
