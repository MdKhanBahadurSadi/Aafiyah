import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_log.dart';
import 'mental_health_repository.dart';

class MentalHealthRepositoryImpl implements MentalHealthRepository {
  @override
  Future<void> addMoodLog(MoodLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final List<MoodLog> logs = await getMoodLogs();
    logs.add(log);
    final String encoded = jsonEncode(logs.map((e) => e.toJson()).toList());
    await prefs.setString('mood_logs', encoded);
  }

  @override
  Future<List<MoodLog>> getMoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString('mood_logs');
    if (encoded != null) {
      final List<dynamic> decoded = jsonDecode(encoded);
      return decoded.map((e) => MoodLog.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<void> clearMoodLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mood_logs');
  }
}
