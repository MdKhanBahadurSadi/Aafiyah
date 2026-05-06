import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../features/tracking/models/health_data.dart' as model;

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  static const List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
  ];

  Future<bool> requestPermissions() async {
    // Requesting permissions for Android & iOS
    await Permission.activityRecognition.request();
    await Permission.location.request();
    
    return await _health.requestAuthorization(types);
  }

  Future<model.HealthData> fetchHealthData() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    try {
      final List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: types,
      );

      int steps = 0;
      double heartRate = 0;
      double sleepSeconds = 0;

      for (var point in healthData) {
        if (point.type == HealthDataType.STEPS) {
          steps += int.parse(point.value.toString());
        } else if (point.type == HealthDataType.HEART_RATE) {
          heartRate = double.parse(point.value.toString());
        } else if (point.type == HealthDataType.SLEEP_ASLEEP) {
          sleepSeconds += double.parse(point.value.toString());
        }
      }

      return model.HealthData(
        steps: steps,
        heartRate: heartRate,
        sleepHours: sleepSeconds / 3600,
        date: now,
      );
    } catch (e) {
      print("Error fetching health data: $e");
      return model.HealthData.empty();
    }
  }
}
