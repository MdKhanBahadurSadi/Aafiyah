import 'dart:convert';
import '../../../core/services/ai_service.dart';
import '../models/symptom_request.dart';
import '../models/symptom_response.dart';
import 'symptom_repository.dart';

class SymptomRepositoryImpl implements SymptomRepository {
  final AIService _aiService = AIService();

  @override
  Future<SymptomResponse> getAdvice(SymptomRequest request) async {
    final prompt = '''
    রোগীর লক্ষণগুলো বিবেচনা করে প্রয়োজনীয় স্বাস্থ্য পরামর্শ প্রদান করুন।
    রোগীর তথ্য: বয়স: ${request.age}, লিঙ্গ: ${request.gender}।
    উপসর্গ: ${request.symptom}, স্থায়িত্ব: ${request.duration}।
    
    বাধ্যতামূলক নিয়ম: "advice" ফিল্ডের মান সম্পূর্ণ স্পষ্ট, সহানুভূতিশীল ও শুদ্ধ বাংলা ভাষায় (বাংলা বর্ণমালায়) প্রদান করুন। কোনো ইংরেজি বাক্য থাকবে না।
    
    শুধুমাত্র একটি বৈধ JSON অবজেক্ট রিটার্ন করুন:
    {
      "advice": "বিস্তারিত স্বাস্থ্য পরামর্শ এবং নির্দেশনা (বাংলায়)",
      "severity": "Low/Medium/High",
      "emergency": true/false,
      "seeDoctor": true/false
    }
    ''';

    final response = await _aiService.getCompletion(prompt);
    
    try {
      // Find the JSON block in case Gemini adds extra text
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      final jsonString = response.substring(jsonStart, jsonEnd);
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return SymptomResponse.fromJson(data);
    } catch (e) {
      return const SymptomResponse(
        advice: "দুঃখিত, এই মুহূর্তে লক্ষণগুলো বিশ্লেষণ করা সম্ভব হয়নি। অসুস্থ বোধ করলে অনুগ্রহ করে একজন অভিজ্ঞ ডাক্তারের পরামর্শ নিন।",
        severity: "Unknown",
        emergency: false,
        seeDoctor: true,
      );
    }
  }
}
