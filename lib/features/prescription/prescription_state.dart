import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aafiyah/features/prescription/models/medicine_model.dart';
import 'package:aafiyah/features/prescription/models/active_medication.dart';
import 'package:aafiyah/features/prescription/repository/prescription_repository.dart';
import 'package:aafiyah/features/prescription/repository/prescription_repository_impl.dart';
import 'package:aafiyah/core/state/app_state.dart';
import 'package:aafiyah/core/services/notification_service.dart';
import 'package:aafiyah/features/gamification/gamification_state.dart';

class PrescriptionState extends ChangeNotifier {
  final PrescriptionRepository _repository = PrescriptionRepositoryImpl();
  final NotificationService _notificationService = NotificationService();
  
  List<MedicineModel> _medicines = [];
  File? _selectedImage;
  List<ActiveMedication> _activeMedications = [];

  List<MedicineModel> get medicines => _medicines;
  File? get selectedImage => _selectedImage;
  List<ActiveMedication> get activeMedications => _activeMedications;

  PrescriptionState() {
    _loadActiveMedications();
  }

  void setImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    _medicines = [];
    notifyListeners();
  }

  Future<void> analyze(AppState appState) async {
    if (_selectedImage == null) {
      appState.setError("Please select a prescription image first.");
      return;
    }

    appState.setLoading(true);
    appState.clearError();
    try {
      _medicines = await _repository.analyzePrescription(_selectedImage!.path);
      if (_medicines.isEmpty) {
        appState.setError("No medicines could be identified. Please try a clearer photo.");
      }
      notifyListeners();
    } catch (e) {
      appState.setError("Analysis failed: ${e.toString()}");
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> _loadActiveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? medsJson = prefs.getString('active_medications');
    if (medsJson != null) {
      final List<dynamic> decoded = jsonDecode(medsJson);
      _activeMedications = decoded.map((item) => ActiveMedication.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveActiveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_activeMedications.map((m) => m.toJson()).toList());
    await prefs.setString('active_medications', encoded);
  }

  Future<void> startRemindersForMedicines() async {
    for (var med in _medicines) {
      final List<int> reminderIds = [];
      final schedule = med.schedule ?? ["Morning"];
      
      // Map common schedule strings to times
      for (var timeStr in schedule) {
        final int reminderId = Random().nextInt(1000000);
        reminderIds.add(reminderId);
        
        DateTime scheduledTime = _getDateTimeForSchedule(timeStr);
        
        await _notificationService.scheduleNotification(
          id: reminderId,
          title: "Medication Reminder: ${med.name}",
          body: "It's time to take ${med.dosage ?? 'your dose'} (${med.relationToFood ?? ''})",
          scheduledTime: scheduledTime,
        );
      }

      final activeMed = ActiveMedication(
        id: DateTime.now().millisecondsSinceEpoch.toString() + med.name,
        medicine: med,
        startDate: DateTime.now(),
        remainingStock: med.stockQuantity ?? 10, // Default if not found
        reminderIds: reminderIds,
      );
      
      _activeMedications.add(activeMed);
    }
    
    await _saveActiveMedications();
    _medicines = []; // Clear current scan after adding to active
    notifyListeners();
  }

  DateTime _getDateTimeForSchedule(String timeStr) {
    final now = DateTime.now();
    int hour = 8;
    int minute = 0;

    if (timeStr.toLowerCase().contains("morning")) {
      hour = 8;
    } else if (timeStr.toLowerCase().contains("noon") || timeStr.toLowerCase().contains("afternoon")) {
      hour = 14;
    } else if (timeStr.toLowerCase().contains("night") || timeStr.toLowerCase().contains("evening")) {
      hour = 21;
    } else if (timeStr.toLowerCase().contains("midnight")) {
      hour = 0;
    }
    
    // Create today's time. If it's already passed, schedule for tomorrow.
    DateTime scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> confirmDoseTaken(String activeMedId, {GamificationState? gamification}) async {
    final index = _activeMedications.indexWhere((m) => m.id == activeMedId);
    if (index != -1) {
      _activeMedications[index].remainingStock -= 1;
      
      // Record gamification
      if (gamification != null) {
        await gamification.recordMedicineTaken();
      }
      
      // Inventory Check: 2/3 days before ending
      // Assuming 3 doses a day for a rough check, or based on schedule length
      int dailyDoses = _activeMedications[index].medicine.schedule?.length ?? 1;
      int lowStockThreshold = dailyDoses * 3; 

      if (_activeMedications[index].remainingStock <= lowStockThreshold && _activeMedications[index].remainingStock > 0) {
        _notificationService.showInstantNotification(
          id: activeMedId.hashCode,
          title: "Low Medicine Stock",
          body: "Your medicine ${_activeMedications[index].medicine.name} will run out in about 3 days. Please restock.",
        );
      } else if (_activeMedications[index].remainingStock <= 0) {
        _notificationService.showInstantNotification(
          id: activeMedId.hashCode,
          title: "Medicine Out of Stock",
          body: "You have run out of ${_activeMedications[index].medicine.name}.",
        );
      }

      await _saveActiveMedications();
      notifyListeners();
    }
  }

  Future<void> removeMedication(String id) async {
    final med = _activeMedications.firstWhere((m) => m.id == id);
    // In a real app, cancel specific notifications here
    _activeMedications.removeWhere((m) => m.id == id);
    await _saveActiveMedications();
    notifyListeners();
  }
}
