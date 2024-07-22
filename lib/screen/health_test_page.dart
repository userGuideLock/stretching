import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:stretching/health/health_service.dart';

class HealthTestViewController extends GetxController {
  final healthService = Get.put(HealthService());

  var steps = 0;
  var heartRate = 0;

  @override
  void onInit() {
    super.onInit();
    fetchHealthData();
  }

  void fetchHealthData() async {
    final healthData = await healthService.fetchHealthData();
    for (var data in healthData) {
      if (data.type == HealthDataType.STEPS) {
        steps += (data.value as double).toInt();
      } else if (data.type == HealthDataType.HEART_RATE) {
        heartRate = (data.value as double).toInt();
      }
    }
    update(); // 상태 업데이트
  }
}

class HealthTestPage extends StatelessWidget {
  const HealthTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HealthTestViewController controller =
        Get.put(HealthTestViewController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Data'),
      ),
      body: Center(
        child: GetBuilder<HealthTestViewController>(
          builder: (controller) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '걸음 수: ${controller.steps}',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Text(
                  '심박수: ${controller.heartRate}',
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
