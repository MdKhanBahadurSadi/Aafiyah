import 'package:aafiyah/features/tracking/models/water_log.dart';
import 'package:aafiyah/features/tracking/models/blood_pressure_log.dart';
import 'package:aafiyah/features/tracking/repository/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final List<WaterLog> _waterLogs = [];
  final List<BloodPressureLog> _bpLogs = [];

  @override
  Future<void> addWaterLog(WaterLog log) async {
    _waterLogs.add(log);
  }

  @override
  Future<List<WaterLog>> getWaterLogs() async {
    return List.from(_waterLogs);
  }

  @override
  Future<void> addBloodPressure(BloodPressureLog log) async {
    _bpLogs.add(log);
  }

  @override
  Future<List<BloodPressureLog>> getBloodPressureLogs() async {
    return List.from(_bpLogs);
  }
}
