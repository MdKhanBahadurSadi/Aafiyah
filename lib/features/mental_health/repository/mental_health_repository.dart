import '../models/mood_log.dart';

abstract class MentalHealthRepository {
  Future<void> addMoodLog(MoodLog log);
  Future<List<MoodLog>> getMoodLogs();
  Future<void> clearMoodLogs();
}
