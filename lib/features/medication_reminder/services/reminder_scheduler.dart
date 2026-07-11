import 'package:flutter/material.dart';
import '../data/models/medication_model.dart';
import '../data/repositories/medication_database.dart';
import '../../../core/services/notification_service.dart';

class ReminderScheduler {
  final NotificationService _notificationService = NotificationService();
  final MedicationDatabase _db = MedicationDatabase();

  Future<void> scheduleMedicationReminders(Medication medication) async {
    // 1. Cancel existing notifications for this medication
    for (int i = 0; i < 100; i++) {
      await _notificationService.cancelNotification(medication.id * 100 + i);
    }

    if (!medication.isActive) return;

    final now = DateTime.now();
    final startDate = medication.startDate.isBefore(now) ? now : medication.startDate;
    final endDate = medication.endDate;

    // Schedule for the next 7 days
    for (int day = 0; day < 7; day++) {
      final targetDate = startDate.add(Duration(days: day));
      
      if (!isDayValid(medication, targetDate)) continue;
      if (endDate != null && targetDate.isAfter(endDate)) break;

      for (int i = 0; i < medication.reminderTimes.length; i++) {
        final time = medication.reminderTimes[i];
        final scheduledDateTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          time.hour,
          time.minute,
        );

        if (scheduledDateTime.isBefore(now)) continue;

        final notificationId = medication.id * 100 + (day * medication.reminderTimes.length) + i;
        
        await _notificationService.scheduleMedicationNotification(
          id: notificationId,
          title: "Time for ${medication.name}",
          body: "${medication.dosage} ${medication.strength ?? ''} - ${medication.foodTiming}",
          scheduledTime: scheduledDateTime,
          payload: 'med_${medication.id}_${scheduledDateTime.millisecondsSinceEpoch}',
        );
      }
    }
  }

  bool isDayValid(Medication medication, DateTime date) {
    switch (medication.frequencyType) {
      case 'daily':
        return true;
      case 'weekly':
        if (medication.weekDays == null) return true;
        return medication.weekDays!.contains(date.weekday);
      case 'interval_days':
        final diff = date.difference(medication.startDate).inDays;
        return diff % (medication.intervalValue ?? 1) == 0;
      default:
        return true;
    }
  }

  Future<void> rescheduleAllActive() async {
    final medications = await _db.getActiveMedications();
    for (final med in medications) {
      await scheduleMedicationReminders(med);
    }
  }
}
