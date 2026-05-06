import 'package:aafiyah/features/tracking/models/water_log.dart';
import 'package:aafiyah/features/tracking/models/blood_pressure_log.dart';

abstract class TrackingRepository {
  Future<void> addWaterLog(WaterLog log);
  Future<List<WaterLog>> getWaterLogs();
  Future<void> addBloodPressure(BloodPressureLog log);
  Future<List<BloodPressureLog>> getBloodPressureLogs();
}
