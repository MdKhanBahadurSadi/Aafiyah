import 'package:isar/isar.dart';

part 'medication_model.g.dart';

@collection
class Medication {
  Id id = Isar.autoIncrement;

  late String name;
  late String dosage;
  String? strength;
  late String type; // Tablet, Capsule, Syrup, Injection, etc.
  
  @Index()
  late DateTime startDate;
  DateTime? endDate;
  
  late List<ReminderTime> reminderTimes;
  
  late String frequencyType; // daily, weekly, interval_days, interval_hours
  List<int>? weekDays; // 1 (Mon) to 7 (Sun)
  int? intervalValue; // X in "Every X days" or "Every X hours"
  
  late String foodTiming; // Before Meal, After Meal, With Meal, No Preference
  String? notes;
  String? doctorName;
  
  bool isActive = true;
  
  DateTime createdAt = DateTime.now();
}

@embedded
class ReminderTime {
  late int hour;
  late int minute;
  
  ReminderTime({this.hour = 0, this.minute = 0});
}

@collection
class MedicationLog {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int medicationId;
  late String medicationName;
  
  @Index()
  late DateTime scheduledTime;
  DateTime? actualTime;
  
  late String status; // taken, missed, skipped, snoozed
  
  String? note;
}
