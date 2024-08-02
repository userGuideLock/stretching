import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stretching/screen/bottom_navigation.dart';
import 'package:stretching/screen/stress/stress_page2.dart';
import 'package:stretching/screen/stress/stress_score_page.dart';

class StressViewController1 extends GetxController {
  bool isLoading = false;
  int currentMessageIndex = 0;
  bool hasError = false;
  String errorMessage = '';
  final Health _health = Health();
  List<HealthDataPoint> healthDataList = [];
  int stressScore = 0;

  int totalSteps = 0;
  int totalSleepMinutes = 0;
  int asleepMinutes = 0;
  int awakeMinutes = 0;
  int deepSleepMinutes = 0;
  int lightSleepMinutes = 0;
  int remSleepMinutes = 0;
  double averageHeartRate = 0.0;
  double respiratoryRate = 0.0;
  DateTime? stepsFetchTime;
  DateTime? sleepFetchTime;
  DateTime? heartRateFetchTime;

  final List<String> loadingMessages = [
    '오늘 심박수를 체크하고 있어요...',
    '최근 수면의 질을 계산하고 있어요...',
    '오늘의 호흡수를 알아보고 있어요...',
    '스트레스 점수를 계산하고 있어요...'
  ];

  @override
  void onInit() {
    super.onInit();
    startLoading();
  }

  void startLoading() async {
    isLoading = true;
    hasError = false;
    update();
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (currentMessageIndex < loadingMessages.length - 1) {
        currentMessageIndex++;
        update();
      } else {
        timer.cancel();
        await fetchHealthData();
        onLoadingComplete();
      }
    });
  }

  Future<void> fetchHealthData() async {
    try {
      await Permission.activityRecognition.request();
      await Permission.location.request();
      await Permission.sensors.request();

      bool? hasPermissions = await _health.hasPermissions(
        [
          HealthDataType.STEPS,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_REM,
          HealthDataType.HEART_RATE,
          HealthDataType.RESPIRATORY_RATE,
        ],
        permissions: [HealthDataAccess.READ_WRITE],
      );
      bool authorized = false;

      if (!hasPermissions!) {
        try {
          authorized = await _health.requestAuthorization(
            [
              HealthDataType.STEPS,
              HealthDataType.SLEEP_ASLEEP,
              HealthDataType.SLEEP_AWAKE,
              HealthDataType.SLEEP_DEEP,
              HealthDataType.SLEEP_LIGHT,
              HealthDataType.SLEEP_REM,
              HealthDataType.HEART_RATE,
              HealthDataType.RESPIRATORY_RATE,
            ],
            permissions: [HealthDataAccess.READ_WRITE],
          );
        } catch (error) {
          throw '권한 부여 중 오류 발생: $error';
        }
      } else {
        authorized = true;
      }

      if (!authorized) {
        throw '점수에 필요한 데이터가 부족합니다.';
      }

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);

      healthDataList = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: [
          HealthDataType.STEPS,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_REM,
          HealthDataType.HEART_RATE,
          HealthDataType.RESPIRATORY_RATE,
        ],
      );

      if (healthDataList.isEmpty || _hasSignificantZeroData()) {
        throw '점수에 필요한 데이터가 부족합니다.';
      }

      // SharedPreferences에 userId 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString('userId');

      _calculateTotals();
      stressScore = calculateTotalScore();
      Get.to(() => StressScorePage(
            stressScore: stressScore,
            userId: userId.toString(),
          ));
    } catch (e) {
      hasError = true;
      errorMessage = '점수에 필요한 데이터가 부족합니다.';
      update();
    }
  }

  bool _hasSignificantZeroData() {
    int zeroCount = 0;
    int dataTypeCount = 8;

    Map<HealthDataType, bool> dataTypePresence = {
      for (var type in [
        HealthDataType.STEPS,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_AWAKE,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_REM,
        HealthDataType.HEART_RATE,
        HealthDataType.RESPIRATORY_RATE,
      ])
        type: false
    };

    for (var point in healthDataList) {
      if (point.value is NumericHealthValue &&
          (point.value as NumericHealthValue).numericValue == 0) {
        zeroCount++;
      }
      dataTypePresence[point.type] = true;
    }

    int missingDataTypes =
        dataTypePresence.values.where((present) => !present).length;

    return zeroCount >= dataTypeCount / 2 || missingDataTypes > 0;
  }

  void _calculateTotals() {
    int heartRateCount = 0;
    int respiratoryRateCount = 0;

    for (var point in healthDataList) {
      if (point.value is NumericHealthValue) {
        var numericValue = (point.value as NumericHealthValue).numericValue;

        if (point.type == HealthDataType.STEPS) {
          totalSteps += numericValue.toInt();
          stepsFetchTime = point.dateTo;
        }
        if (point.type == HealthDataType.HEART_RATE) {
          averageHeartRate += numericValue;
          heartRateCount++;
          heartRateFetchTime = point.dateTo;
        }
        if (point.type == HealthDataType.RESPIRATORY_RATE) {
          respiratoryRate += numericValue;
          respiratoryRateCount++;
        }
        if (point.type == HealthDataType.SLEEP_ASLEEP) {
          asleepMinutes += numericValue.toInt();
          sleepFetchTime = point.dateTo;
        }
        if (point.type == HealthDataType.SLEEP_AWAKE) {
          awakeMinutes += numericValue.toInt();
        }
        if (point.type == HealthDataType.SLEEP_DEEP) {
          deepSleepMinutes += numericValue.toInt();
        }
        if (point.type == HealthDataType.SLEEP_LIGHT) {
          lightSleepMinutes += numericValue.toInt();
        }
        if (point.type == HealthDataType.SLEEP_REM) {
          remSleepMinutes += numericValue.toInt();
        }
      }
    }

    if (heartRateCount > 0) {
      averageHeartRate /= heartRateCount;
    } else {
      averageHeartRate = 0;
    }

    if (respiratoryRateCount > 0) {
      respiratoryRate /= respiratoryRateCount;
    } else {
      respiratoryRate = 0;
    }
  }

  double get totalSleepHours => totalSleepMinutes / 60;

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

  void onLoadingComplete() {
    isLoading = false;
    update();
  }
}

class StressPage1 extends StatelessWidget {
  const StressPage1({super.key});

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
      body: GetBuilder<StressViewController1>(
        init: StressViewController1(),
        builder: (controller) {
          return Stack(
            children: [
              if (!controller.isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      if (controller.hasError)
                        Text(
                          controller.errorMessage,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        '몇 가지 항목을 선택하고 오늘의 스트레스 점수를 알아보세요',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Image.asset(
                        "images/splash_page_star.png",
                        width: double.infinity,
                      ),
                      const SizedBox(
                        height: 120,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: const Color(0xffacdcb4), // 텍스트 색상
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            // 로그인 버튼 클릭 시 처리할 로직
                            Get.to(const StressPage2());
                          },
                          child: const Text(
                            '다음',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      if (!controller.hasError)
                        const Text(
                          '데이터를 불러오지 못했습니다.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              if (controller.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            controller.loadingMessages[
                                controller.currentMessageIndex],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
