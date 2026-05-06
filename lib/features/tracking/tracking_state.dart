import 'package:flutter/material.dart';
import 'package:aafiyah/features/tracking/models/water_log.dart';
import 'package:aafiyah/features/tracking/models/blood_pressure_log.dart';
import 'package:aafiyah/features/tracking/models/bmi_result.dart';
import 'package:aafiyah/features/tracking/repository/tracking_repository.dart';
import 'package:aafiyah/features/tracking/repository/tracking_repository_impl.dart';
import 'package:aafiyah/features/gamification/gamification_state.dart';

class TrackingState extends ChangeNotifier {
  final TrackingRepository _repository = TrackingRepositoryImpl();
  
  List<WaterLog> _waterLogs = [];
  List<BloodPressureLog> _bpLogs = [];
  final int waterGoalMl = 2000; // Default goal

  List<WaterLog> get waterLogs => _waterLogs;
  List<BloodPressureLog> get bpLogs => _bpLogs;

  TrackingState() {
    loadLogs();
  }

  int get todayWaterTotal {
    final now = DateTime.now();
    return _waterLogs
        .where((log) => 
            log.date.year == now.year && 
            log.date.month == now.month && 
            log.date.day == now.day)
        .fold(0, (sum, log) => sum + log.amountMl);
  }

  Future<void> addWater(int amountMl, {GamificationState? gamification}) async {
    final log = WaterLog(date: DateTime.now(), amountMl: amountMl);
    await _repository.addWaterLog(log);
    _waterLogs = await _repository.getWaterLogs();
    
    // Check if goal reached for gamification
    if (gamification != null && todayWaterTotal >= waterGoalMl) {
      await gamification.recordWaterGoalReached();
    }

    notifyListeners();
  }

  Future<void> addBloodPressure(int systolic, int diastolic) async {
    final log = BloodPressureLog(
      systolic: systolic,
      diastolic: diastolic,
      date: DateTime.now(),
    );
    await _repository.addBloodPressure(log);
    _bpLogs = await _repository.getBloodPressureLogs();
    notifyListeners();
  }

  BMIResult calculateBMI(double heightCm, double weightKg) {
    if (heightCm <= 0) return const BMIResult(value: 0, category: "Invalid Height");
    final heightM = heightCm / 100;
    final bmiValue = weightKg / (heightM * heightM);
    
    String category;
    if (bmiValue < 18.5) {
      category = "Underweight";
    } else if (bmiValue < 25) {
      category = "Normal";
    } else if (bmiValue < 30) {
      category = "Overweight";
    } else {
      category = "Obese";
    }
    
    return BMIResult(value: bmiValue, category: category);
  }

  String generateWeeklySummary() {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    final weeklyWater = _waterLogs
        .where((log) => log.date.isAfter(sevenDaysAgo))
        .fold(0, (sum, log) => sum + log.amountMl).toInt();
        
    final weeklyBP = _bpLogs
        .where((log) => log.date.isAfter(sevenDaysAgo))
        .length;

    return "You logged $weeklyWater ml water this week and $weeklyBP BP entries.";
  }

  Future<void> loadLogs() async {
    _waterLogs = await _repository.getWaterLogs();
    _bpLogs = await _repository.getBloodPressureLogs();
    notifyListeners();
  }
}
