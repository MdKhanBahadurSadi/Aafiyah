import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/medication_model.dart';

class MedicationDatabase {
  static late Isar _isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [MedicationSchema, MedicationLogSchema],
      directory: dir.path,
    );
  }

  // Medication CRUD
  Future<int> saveMedication(Medication medication) async {
    return await _isar.writeTxn(() async {
      return await _isar.medications.put(medication);
    });
  }

  Future<List<Medication>> getAllMedications() async {
    return await _isar.medications.where().findAll();
  }

  Future<Medication?> getMedicationById(Id id) async {
    return await _isar.medications.get(id);
  }

  Future<void> deleteMedication(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.medications.delete(id);
      // Also delete logs for this medication
      await _isar.medicationLogs.filter().medicationIdEqualTo(id).deleteAll();
    });
  }

  // Logs CRUD
  Future<void> saveLog(MedicationLog log) async {
    await _isar.writeTxn(() async {
      await _isar.medicationLogs.put(log);
    });
  }

  Future<List<MedicationLog>> getLogsForMedication(int medicationId) async {
    return await _isar.medicationLogs
        .filter()
        .medicationIdEqualTo(medicationId)
        .sortByScheduledTimeDesc()
        .findAll();
  }

  Future<List<MedicationLog>> getLogsByDateRange(DateTime start, DateTime end) async {
    return await _isar.medicationLogs
        .filter()
        .scheduledTimeBetween(start, end)
        .sortByScheduledTime()
        .findAll();
  }

  // Helper for dashboard: Today's scheduled meds
  Future<List<Medication>> getActiveMedications() async {
    return await _isar.medications.filter().isActiveEqualTo(true).findAll();
  }
}
