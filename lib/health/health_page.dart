import 'dart:io';

import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

enum AppState {
  DATA_NOT_FETCHED, // 데이터가 가져오지 않음
  FETCHING_DATA, // 데이터 가져오는 중
  DATA_READY, // 데이터 준비 완료
  NO_DATA, // 데이터 없음
  AUTHORIZED, // 권한 부여됨
  AUTH_NOT_GRANTED, // 권한 부여되지 않음
}

class HealthViewController extends GetxController {
  final Health _health = Health();

  var healthDataList = <HealthDataPoint>[];
  var state = AppState.DATA_NOT_FETCHED;

  var totalSteps = 0;
  var totalSleepMinutes = 0;
  var averageHeartRate = 0.0;

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
    Health().configure(useHealthConnectIfAvailable: true);
    super.onInit();
  }

  Future<void> installHealthConnect() async {
    await Health().installHealthConnect();
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
  }

  Future<void> fetchHealthData() async {
    state = AppState.FETCHING_DATA;
    update();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    healthDataList.clear();
    totalSteps = 0;
    totalSleepMinutes = 0;
    averageHeartRate = 0.0;

    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: todayStart,
        endTime: now,
      );

      healthDataList.addAll(healthData);
      _calculateTotals();
    } catch (error) {
      print("getHealthDataFromTypes에서 예외 발생: $error");
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
        }
        if (point.type == HealthDataType.HEART_RATE) {
          averageHeartRate += numericValue;
          heartRateCount++;
        }
        if (point.type == HealthDataType.SLEEP_ASLEEP ||
            point.type == HealthDataType.SLEEP_AWAKE ||
            point.type == HealthDataType.SLEEP_DEEP ||
            point.type == HealthDataType.SLEEP_LIGHT ||
            point.type == HealthDataType.SLEEP_REM) {
          totalSleepMinutes += numericValue.toInt();
        }
      }
    }

    if (heartRateCount > 0) {
      averageHeartRate /= heartRateCount;
    }
  }

  double get totalSleepHours => totalSleepMinutes / 60;
}

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('건강 예제'),
      ),
      body: GetBuilder<HealthViewController>(
        init: HealthViewController(),
        builder: (controller) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 10,
                children: [
                  TextButton(
                    onPressed: controller.authorize,
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                    ),
                    child:
                        const Text("인증", style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: controller.fetchHealthData,
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                    ),
                    child: const Text("데이터 가져오기",
                        style: TextStyle(color: Colors.white)),
                  ),
                  if (Platform.isAndroid)
                    TextButton(
                      onPressed: controller.installHealthConnect,
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      ),
                      child: const Text("Health Connect 설치",
                          style: TextStyle(color: Colors.white)),
                    ),
                ],
              ),
              const Divider(thickness: 3),
              Expanded(child: Center(child: _buildContent(controller))),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(HealthViewController controller) {
    switch (controller.state) {
      case AppState.DATA_READY:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("총 걸음 수: ${controller.totalSteps}"),
            Text(
                "총 수면 시간: ${controller.totalSleepHours.toStringAsFixed(2)} 시간"),
            Text(
                "평균 심박수: ${controller.averageHeartRate.toStringAsFixed(2)} bpm"),
          ],
        );
      case AppState.AUTH_NOT_GRANTED:
        return const Text('권한이 부여되지 않았습니다. 모든 건강 권한을 부여해야 합니다.');
      case AppState.FETCHING_DATA:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 10),
            Text('데이터 가져오는 중...')
          ],
        );
      case AppState.NO_DATA:
        return const Text('표시할 데이터가 없습니다');
      case AppState.DATA_NOT_FETCHED:
      default:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("권한을 얻으려면 '인증'을 누르세요."),
            Text("건강 데이터를 가져오려면 '데이터 가져오기'를 누르세요."),
          ],
        );
    }
  }
}
