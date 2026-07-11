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
    ব্যবহারকারী গত ৩ দিন ধরে $moodSummary অনুভব করছেন।
    "আফি" (Aafi) হিসেবে তাদের একজন সহানুভূতিশীল সঙ্গী হিসেবে সম্পূর্ণ বাংলা ভাষায় (বাংলা বর্ণমালায়) প্রতিক্রিয়া দিন।
    ১. তাদের অনুভূতির প্রতি গভীর সমবেদনা ও সহমর্মিতা প্রকাশ করুন।
    ২. একটি সহজ মাইন্ডফুলনেস চর্চা বা মন হালকা করার মতো ছোট কার্যক্রমের পরামর্শ দিন।
    ৩. ধৈর্য (সবর) বা আশা (রজা) সম্পর্কিত একটি ছোট কোরআনের আয়াত বা হাদিসের অর্থ উল্লেখ করুন।
    ৪. মনে করিয়ে দিন যে তারা একা নন এবং আল্লাহ সাথে আছেন।
    ৫. অনুভূতি দীর্ঘদিন স্থায়ী হলে কখন ডাক্তারের কাছে যাওয়া উচিত তা বুঝিয়ে বলুন।
    
    সমস্ত টেক্সট ১০০% বাংলা ভাষায় হতে হবে।
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
