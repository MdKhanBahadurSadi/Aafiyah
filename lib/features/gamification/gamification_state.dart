import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_progress.dart';

class GamificationState extends ChangeNotifier {
  UserProgress _progress = UserProgress.initial();

  UserProgress get progress => _progress;

  GamificationState() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('user_progress');
    if (data != null) {
      _progress = UserProgress.fromJson(jsonDecode(data));
      notifyListeners();
    }
    // Record login streak when app loads
    await recordLogin();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_progress', jsonEncode(_progress.toJson()));
  }

  Future<void> recordLogin() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(_progress.lastLoginDate.year, _progress.lastLoginDate.month, _progress.lastLoginDate.day);

    if (today.isAfter(lastLogin)) {
      int newStreak = _progress.loginStreak;
      if (today.difference(lastLogin).inDays == 1) {
        newStreak++;
      } else {
        newStreak = 1;
      }

      int pointsToAdd = 5;
      List<String> newBadges = List.from(_progress.earnedBadges);

      if (newStreak == 7 && !newBadges.contains('login_7_day')) {
        newBadges.add('login_7_day');
        pointsToAdd += 30;
      }

      _progress = _progress.copyWith(
        totalPoints: _progress.totalPoints + pointsToAdd,
        loginStreak: newStreak,
        lastLoginDate: now,
        earnedBadges: newBadges,
      );

      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> recordMedicineTaken() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastTaken = DateTime(_progress.lastMedicineDate.year, _progress.lastMedicineDate.month, _progress.lastMedicineDate.day);

    if (today.isAfter(lastTaken)) {
      int newStreak = _progress.medicineStreak;
      if (today.difference(lastTaken).inDays == 1) {
        newStreak++;
      } else {
        newStreak = 1;
      }

      int pointsToAdd = 10;
      List<String> newBadges = List.from(_progress.earnedBadges);

      if (newStreak == 7 && !newBadges.contains('medicine_7_day')) {
        newBadges.add('medicine_7_day');
        pointsToAdd += 50;
      }

      _progress = _progress.copyWith(
        totalPoints: _progress.totalPoints + pointsToAdd,
        medicineStreak: newStreak,
        lastMedicineDate: now,
        earnedBadges: newBadges,
      );

      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> recordStepsGoalReached() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStep = DateTime(_progress.lastStepDate.year, _progress.lastStepDate.month, _progress.lastStepDate.day);

    if (today.isAfter(lastStep)) {
      int newStreak = _progress.stepStreak;
      if (today.difference(lastStep).inDays == 1) {
        newStreak++;
      } else {
        newStreak = 1;
      }

      int pointsToAdd = 20;
      List<String> newBadges = List.from(_progress.earnedBadges);

      if (newStreak == 7 && !newBadges.contains('steps_7_day')) {
        newBadges.add('steps_7_day');
        pointsToAdd += 100;
      }

      _progress = _progress.copyWith(
        totalPoints: _progress.totalPoints + pointsToAdd,
        stepStreak: newStreak,
        lastStepDate: now,
        earnedBadges: newBadges,
      );

      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> recordWaterGoalReached() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWater = DateTime(_progress.lastWaterDate.year, _progress.lastWaterDate.month, _progress.lastWaterDate.day);

    if (today.isAfter(lastWater)) {
      int newStreak = _progress.waterStreak;
      if (today.difference(lastWater).inDays == 1) {
        newStreak++;
      } else {
        newStreak = 1;
      }

      int pointsToAdd = 15;
      List<String> newBadges = List.from(_progress.earnedBadges);

      if (newStreak == 7 && !newBadges.contains('water_7_day')) {
        newBadges.add('water_7_day');
        pointsToAdd += 70;
      }

      _progress = _progress.copyWith(
        totalPoints: _progress.totalPoints + pointsToAdd,
        waterStreak: newStreak,
        lastWaterDate: now,
        earnedBadges: newBadges,
      );

      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> recordMoodLogged() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastMood = DateTime(_progress.lastMoodDate.year, _progress.lastMoodDate.month, _progress.lastMoodDate.day);

    if (today.isAfter(lastMood)) {
      int newStreak = _progress.moodStreak;
      if (today.difference(lastMood).inDays == 1) {
        newStreak++;
      } else {
        newStreak = 1;
      }

      int pointsToAdd = 10;
      List<String> newBadges = List.from(_progress.earnedBadges);

      if (newStreak == 7 && !newBadges.contains('mood_7_day')) {
        newBadges.add('mood_7_day');
        pointsToAdd += 50;
      }

      _progress = _progress.copyWith(
        totalPoints: _progress.totalPoints + pointsToAdd,
        moodStreak: newStreak,
        lastMoodDate: now,
        earnedBadges: newBadges,
      );

      await _saveProgress();
      notifyListeners();
    }
  }
}
