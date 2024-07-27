import 'dart:io';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum AppState {
  DATA_NOT_FETCHED, // 데이터가 가져오지 않음
  FETCHING_DATA, // 데이터 가져오는 중
  DATA_READY, // 데이터 준비 완료
  NO_DATA, // 데이터 없음
  AUTHORIZED, // 권한 부여됨
  AUTH_NOT_GRANTED, // 권한 부여되지 않음
  AUTH_REQUIRED, // 사용자가 로그인 해야함
}

class HomeViewController extends GetxController {
  final Health _health = Health();

  var healthDataList = <HealthDataPoint>[];
  var state = AppState.DATA_NOT_FETCHED;

  var totalSteps = 0;
  var totalSleepMinutes = 0;
  var asleepMinutes = 0;
  var awakeMinutes = 0;
  var deepSleepMinutes = 0;
  var lightSleepMinutes = 0;
  var remSleepMinutes = 0;
  var averageHeartRate = 0.0; // 평균값 초기화
  var respiratoryRate = 0.0; // 평균값 초기화
  var stressScore = 0; // 초기 스트레스 점수
  DateTime? lastFetchTime;

  DateTime? stepsFetchTime;
  DateTime? sleepFetchTime;
  DateTime? heartRateFetchTime;

  static final types = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.HEART_RATE,
    HealthDataType.RESPIRATORY_RATE,
  ];

  List<HealthDataAccess> get permissions =>
      types.map((e) => HealthDataAccess.READ_WRITE).toList();

  @override
  void onInit() {
    Health().configure(useHealthConnectIfAvailable: true);
    super.onInit();
    checkInternetAndAuthorize();
  }

  Future<void> checkInternetAndAuthorize() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showInternetSnackbar();
    } else {
      await authorize(); // 인터넷 연결되어 있으면 권한 확인 및 데이터 가져오기
    }
  }

  Future<void> authorize() async {
    // 모든 관련 권한 요청
    await Permission.activityRecognition.request();
    await Permission.location.request();
    await Permission.sensors.request();

    bool? hasPermissions =
        await _health.hasPermissions(types, permissions: permissions);
    bool authorized = false;
    if (!hasPermissions!) {
      try {
        authorized =
            await _health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        debugPrint("권한 부여 중 예외 발생: $error");
      }
    } else {
      authorized = true;
    }
    state = authorized ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED;
    update();

    if (state == AppState.AUTH_NOT_GRANTED) {
      _showAuthorizationSnackbar();
    } else {
      fetchHealthData();
    }
  }

  Future<void> fetchHealthData() async {
    if (state != AppState.AUTHORIZED) {
      await authorize();
    }

    if (state != AppState.AUTHORIZED) {
      return;
    }

    state = AppState.FETCHING_DATA;
    update();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month - 1, now.day);
    healthDataList.clear();
    totalSteps = 0;
    totalSleepMinutes = 0;
    asleepMinutes = 0;
    awakeMinutes = 0;
    deepSleepMinutes = 0;
    lightSleepMinutes = 0;
    remSleepMinutes = 0;
    averageHeartRate = 0.0; // 평균값 초기화
    respiratoryRate = 0.0; // 평균값 초기화

    try {
      // 걸음수 데이터 가져오기 (오늘)
      List<HealthDataPoint> stepsData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: todayStart,
        endTime: now,
      );

      // 나머지 데이터 가져오기 (한 달 이내)
      List<HealthDataPoint> otherData = await _health.getHealthDataFromTypes(
        types: types.where((type) => type != HealthDataType.STEPS).toList(),
        startTime: monthStart,
        endTime: now,
      );

      debugPrint(
          "Fetched health data: ${stepsData.length + otherData.length} points");

      healthDataList.addAll(stepsData);
      healthDataList.addAll(otherData);
      _calculateTotals();
      lastFetchTime = now; // 데이터 가져온 시간 저장
      stressScore = calculateTotalScore(); // 스트레스 점수 업데이트
    } catch (error) {
      debugPrint("getHealthDataFromTypes에서 예외 발생: $error");
    }
    healthDataList = _health.removeDuplicates(healthDataList);
    state = healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    update();
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
      averageHeartRate = 60.0; // 기본 평균값 사용
    }

    if (respiratoryRateCount > 0) {
      respiratoryRate /= respiratoryRateCount;
    } else {
      respiratoryRate = 16.0; // 기본 평균값 사용
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
    if (averageHeartRate == 0) return 5;
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
    if (respiratoryRate == 0) return 10;
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

  void _showAuthorizationSnackbar() {
    Get.snackbar(
      '권한이 필요합니다',
      '이 앱은 건강 데이터를 가져오기 위해 권한이 필요합니다. 설정에서 권한을 부여해주세요.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          openAppSettings();
        },
        child: const Text(
          '설정으로 이동',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showLoginSnackbar() {
    Get.snackbar(
      '로그인이 필요합니다',
      '헬스 커넥터를 설치하여 허용해주세요.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          fetchHealthData();
        },
        child: const Text(
          '로그인',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showInternetSnackbar() {
    Get.snackbar(
      '인터넷 연결 필요',
      '이 앱은 데이터를 가져오기 위해 인터넷 연결이 필요합니다. 인터넷 연결을 확인해주세요.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeViewController>(
      init: HomeViewController(),
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
                mainAxisAlignment: MainAxisAlignment.start,
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
          ),
          body: RefreshIndicator(
            onRefresh: controller.fetchHealthData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      '오늘의 스트레스 점수는?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '수면, 심박수, 심전도 및 사용자의 선택한 데이터를 기반으로\n스트레스 점수를 계산합니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    _buildDataBox(
                      icon: controller.state == AppState.NO_DATA
                          ? Icons.help_outline
                          : Icons.emoji_emotions,
                      title: '스트레스 점수',
                      value: controller.state == AppState.NO_DATA
                          ? '가져올 데이터가 없습니다.'
                          : '${controller.stressScore} / 100',
                      subTitle: '',
                      fetchTime: controller.lastFetchTime,
                      image: 'images/home_page_box.png',
                    ),
                    const SizedBox(height: 16),
                    _buildDataBox(
                      icon: Icons.directions_walk,
                      title: '걸음수',
                      value: controller.totalSteps.toString(),
                      subTitle: 'steps',
                      fetchTime: controller.stepsFetchTime,
                      image: 'images/home_page_box.png',
                    ),
                    const SizedBox(height: 16),
                    _buildDataBox(
                      icon: Icons.bed,
                      title: '수면(전체)',
                      value:
                          '${controller.totalSleepHours.toStringAsFixed(1)}h',
                      subTitle: 'total sleep time',
                      fetchTime: controller.sleepFetchTime,
                      image: 'images/home_page_box.png',
                    ),
                    const SizedBox(height: 16),
                    _buildDataBox(
                      icon: Icons.night_shelter,
                      title: '수면(깨어있는 시간)',
                      value: '${controller.awakeMinutes}m',
                      subTitle: 'awake time',
                      fetchTime: controller.sleepFetchTime,
                      image: 'images/home_page_box.png',
                    ),
                    const SizedBox(height: 16),
                    _buildDataBox(
                      icon: Icons.nightlight_round,
                      title: '수면(깊은 수면)',
                      value: '${controller.deepSleepMinutes}m',
                      subTitle: 'deep sleep',
                      fetchTime: controller.sleepFetchTime,
                      image: 'images/home_page_box.png',
                    ),
                    const SizedBox(height: 16),
                    _buildDataBox(
                      icon: Icons.bedtime,
                      title: '수면(얕은 수면)',
                      value: '${controller.lightSleepMinutes}m',
                      subTitle: 'light sleep',
                      fetchTime: controller.sleepFetchTime,
                      image: 'images/home_page_box.png',
                    ),
                    const SizedBox(height: 16),
                    _buildDataBox(
                      icon: Icons.bedroom_baby,
                      title: '수면(REM 수면)',
                      value: '${controller.remSleepMinutes}m',
                      subTitle: 'REM sleep',
                      fetchTime: controller.sleepFetchTime,
                      image: 'images/home_page_box.png',
                    ),
                    const SizedBox(height: 16),
                    _buildDataBox(
                      icon: Icons.favorite,
                      title: '심박수',
                      value: controller.averageHeartRate.toStringAsFixed(1),
                      subTitle: 'BPM',
                      fetchTime: controller.heartRateFetchTime,
                      image: 'images/home_page_box.png',
                    ),
                    const SizedBox(height: 16),
                    _buildDataBox(
                      icon: Icons.air,
                      title: '호흡률',
                      value: controller.respiratoryRate.toStringAsFixed(1),
                      subTitle: 'BPM',
                      fetchTime: controller.sleepFetchTime,
                      image: 'images/home_page_box.png',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataBox({
    required IconData icon,
    required String title,
    required String value,
    required String subTitle,
    required DateTime? fetchTime,
    required String image,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                subTitle,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              if (fetchTime != null)
                Text(
                  '$fetchTime',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
          Icon(icon, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}
