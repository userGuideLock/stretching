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
  var averageHeartRate = 0.0;
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
  ];

  List<HealthDataAccess> get permissions =>
      types.map((e) => HealthDataAccess.READ_WRITE).toList();

  @override
  void onInit() {
    super.onInit();
    checkInternetAndAuthorize(); // 화면에 들어오자마자 권한 및 데이터 가져오기
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
    debugPrint("Requesting permissions...");
    await Permission.activityRecognition.request();
    await Permission.location.request();
    await Permission.sensors.request();

    var activityRecognitionStatus = await Permission.activityRecognition.status;
    var locationStatus = await Permission.location.status;
    var sensorsStatus = await Permission.sensors.status;

    if (activityRecognitionStatus.isGranted &&
        locationStatus.isGranted &&
        sensorsStatus.isGranted) {
      debugPrint("All necessary permissions granted.");
    } else {
      debugPrint(
          "Permissions not granted. activityRecognition: $activityRecognitionStatus, location: $locationStatus, sensors: $sensorsStatus");
      return;
    }

    bool? hasPermissions =
        await _health.hasPermissions(types, permissions: permissions);
    debugPrint("Initial permission check: $hasPermissions");

    if (hasPermissions == null || !hasPermissions) {
      try {
        bool authorized =
            await _health.requestAuthorization(types, permissions: permissions);
        debugPrint("Authorization result: $authorized");
        state = authorized ? AppState.AUTHORIZED : AppState.AUTH_NOT_GRANTED;
      } catch (error) {
        debugPrint("권한 부여 중 예외 발생: $error");
        state = AppState.AUTH_NOT_GRANTED;
      }
    } else {
      state = AppState.AUTHORIZED;
    }

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
    healthDataList.clear();
    totalSteps = 0;
    totalSleepMinutes = 0;
    asleepMinutes = 0;
    awakeMinutes = 0;
    deepSleepMinutes = 0;
    lightSleepMinutes = 0;
    remSleepMinutes = 0;
    averageHeartRate = 0.0;

    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: todayStart,
        endTime: now,
      );

      debugPrint("Fetched health data: ${healthData.length} points");

      healthDataList.addAll(healthData);
      _calculateTotals();
      lastFetchTime = now; // 데이터 가져온 시간 저장
    } catch (error) {
      debugPrint("getHealthDataFromTypes에서 예외 발생: $error");
    }
    healthDataList = _health.removeDuplicates(healthDataList);
    state = healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
    update();
  }

  void _calculateTotals() {
    int heartRateCount = 0;

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
        if (point.type == HealthDataType.SLEEP_ASLEEP ||
            point.type == HealthDataType.SLEEP_AWAKE ||
            point.type == HealthDataType.SLEEP_DEEP ||
            point.type == HealthDataType.SLEEP_LIGHT ||
            point.type == HealthDataType.SLEEP_REM) {
          totalSleepMinutes += numericValue.toInt();
          sleepFetchTime = point.dateTo;
        }
      }
    }

    if (heartRateCount > 0) {
      averageHeartRate /= heartRateCount;
    }
  }

  double get totalSleepHours => totalSleepMinutes / 60;

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
      '이 앱은 Google Fit 또는 Apple Health에 로그인해야 데이터를 가져올 수 있습니다. 로그인 이후 헬스 커넥터를 설치하여 허용해주세요.',
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
                    if (controller.lastFetchTime != null)
                      Text(
                        '데이터 업데이트 시간: ${controller.lastFetchTime}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    if (controller.state == AppState.NO_DATA)
                      const Text(
                        '가져올 데이터가 없습니다.',
                        style: TextStyle(color: Colors.red, fontSize: 14),
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
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
