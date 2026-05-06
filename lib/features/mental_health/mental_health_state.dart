import 'package:flutter/material.dart';
import '../../core/services/ai_service.dart';
import 'models/mood_log.dart';
import 'repository/mental_health_repository.dart';
import 'repository/mental_health_repository_impl.dart';
import 'package:aafiyah/features/gamification/gamification_state.dart';

class MentalHealthState extends ChangeNotifier {
  final MentalHealthRepository _repository = MentalHealthRepositoryImpl();
  final AIService _aiService = AIService();

  List<MoodLog> _moodLogs = [];
  String? _aiSupportMessage;
  bool _isGeneratingSupport = false;

  List<MoodLog> get moodLogs => _moodLogs;
  String? get aiSupportMessage => _aiSupportMessage;
  bool get isGeneratingSupport => _isGeneratingSupport;

  MentalHealthState() {
    loadLogs();
  }

  Future<void> addMood(String mood, String? note, {GamificationState? gamification}) async {
    final log = MoodLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      mood: mood,
      note: note,
    );
    await _repository.addMoodLog(log);
    _moodLogs = await _repository.getMoodLogs();
    
    // Record gamification
    if (gamification != null) {
      await gamification.recordMoodLogged();
    }
    
    // Check if mood is sad/anxious for several days
    await _checkMentalStatus();
    notifyListeners();
  }

  Future<void> loadLogs() async {
    _moodLogs = await _repository.getMoodLogs();
    notifyListeners();
  }

  Future<void> _checkMentalStatus() async {
    if (_moodLogs.length < 3) return;
    
    final lastThree = _moodLogs.reversed.take(3).toList();
    final isStruggling = lastThree.every((log) => 
      log.mood.toLowerCase() == "sad" || 
      log.mood.toLowerCase() == "anxious" || 
      log.mood.toLowerCase() == "depressed" ||
      log.mood.toLowerCase() == "angry"
    );

    if (isStruggling) {
      await _generateSupportMessage(lastThree);
    } else {
      _aiSupportMessage = null;
    }
  }

  Future<void> _generateSupportMessage(List<MoodLog> recentLogs) async {
    _isGeneratingSupport = true;
    notifyListeners();

    final moodSummary = recentLogs.map((e) => e.mood).join(", ");
    final prompt = '''
    User has been feeling $moodSummary for the last 3 days. 
    As "Aafi", their virtual companion, provide a warm, empathetic response in Bengali (বাংলা).
    1. Offer comfort and validation of their feelings.
    2. Suggest a simple mindfulness exercise or a small relaxing activity.
    3. Include a short Quranic verse or a Hadith related to patience (Sabr) or hope (Raja).
    4. Remind them they are not alone and that Allah is with them.
    5. Suggest when to seek professional help if feelings persist.
    ''';

    try {
      _aiSupportMessage = await _aiService.getCompletion(prompt);
    } catch (e) {
      print("Error generating mental health support: $e");
    } finally {
      _isGeneratingSupport = false;
      notifyListeners();
    }
  }

  void clearSupportMessage() {
    _aiSupportMessage = null;
    notifyListeners();
  }
}
