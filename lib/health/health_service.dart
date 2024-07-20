import 'package:get/get.dart';
import 'package:health/health.dart';

class HealthService extends GetxService {
  final Health _health = Health();

  Future<List<HealthDataPoint>> fetchHealthData() async {
    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    bool requested =
        await _health.requestAuthorization(types, permissions: permissions);
    if (requested) {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      return await _health.getHealthDataFromTypes(
        types: types,
        startTime: midnight,
        endTime: now,
      );
    }
    return [];
  }
}
