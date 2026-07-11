import 'package:flutter/material.dart';
import '../../data/models/medication_model.dart';
import '../../data/repositories/medication_database.dart';
import '../../services/reminder_scheduler.dart';

class MedicationState extends ChangeNotifier {
  final MedicationDatabase _db = MedicationDatabase();
  final ReminderScheduler _scheduler = ReminderScheduler();

  List<Medication> _medications = [];
  List<MedicationLog> _todayLogs = [];
  bool _isLoading = false;

  List<Medication> get medications => _medications;
  List<MedicationLog> get todayLogs => _todayLogs;
  bool get isLoading => _isLoading;

  Future<void> loadMedications() async {
    _isLoading = true;
    notifyListeners();
    
    _medications = await _db.getAllMedications();
    await _loadTodayLogs();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTodayLogs() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    _todayLogs = await _db.getLogsByDateRange(startOfDay, endOfDay);
  }

  Future<void> addMedication(Medication medication) async {
    final id = await _db.saveMedication(medication);
    medication.id = id;
    await _scheduler.scheduleMedicationReminders(medication);
    await loadMedications();
  }

  Future<void> updateMedication(Medication medication) async {
    await _db.saveMedication(medication);
    await _scheduler.scheduleMedicationReminders(medication);
    await loadMedications();
  }

  Future<void> deleteMedication(int id) async {
    await _db.deleteMedication(id);
    // Notification cancellation is handled inside deleteMedication or here
    await loadMedications();
  }

  Future<void> markAsTaken(Medication medication, DateTime scheduledTime) async {
    final log = MedicationLog()
      ..medicationId = medication.id
      ..medicationName = medication.name
      ..scheduledTime = scheduledTime
      ..actualTime = DateTime.now()
      ..status = 'taken';
    
    await _db.saveLog(log);
    await _loadTodayLogs();
    notifyListeners();
  }

  Future<void> markAsMissed(Medication medication, DateTime scheduledTime) async {
    final log = MedicationLog()
      ..medicationId = medication.id
      ..medicationName = medication.name
      ..scheduledTime = scheduledTime
      ..status = 'missed';
    
    await _db.saveLog(log);
    await _loadTodayLogs();
    notifyListeners();
  }

  // Adherence calculation
  double getAdherenceRate(DateTime start, DateTime end) {
    // This would ideally fetch logs for the range and calculate
    return 0.85; // Placeholder
  }
}
