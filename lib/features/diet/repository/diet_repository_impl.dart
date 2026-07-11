import 'dart:convert';
import '../../../core/services/ai_service.dart';
import '../models/diet_plan.dart';
import 'diet_repository.dart';

class DietRepositoryImpl implements DietRepository {
  final AIService _aiService = AIService();

  @override
  Future<DietPlan> generateDietPlan({
    required int age,
    required String gender,
    required String symptoms,
    required String healthStatus,
    required List<String> preferences,
    required List<String> restrictions,
  }) async {
    final prompt = '''
    নিচের রোগীর তথ্যের ওপর ভিত্তি করে একটি দৈনিক খাদ্য ও পুষ্টি পরিকল্পনা (Diet Plan) তৈরি করুন:
    বয়স: $age
    লিঙ্গ: $gender
    উপসর্গ: $symptoms
    বর্তমান স্বাস্থ্য অবস্থা: $healthStatus
    খাদ্য পছন্দ: ${preferences.join(", ")}
    খাদ্য বিধিনিষেধ: ${restrictions.join(", ")}
    
    পরিকল্পনাটি স্বাস্থ্যকর, ভারসাম্যপূর্ণ এবং ইসলামি খাদ্য নীতি (হালাল) অনুসরণকারী হতে হবে।
    শিরোনাম, বিবরণ, প্রতিটি বেলার খাবার ও সমস্ত পরামর্শ বাধ্যতামূলকভাবে ১০০% সহজ বাংলা ভাষায় (বাংলা বর্ণমালায়) হতে হবে।
    
    শুধুমাত্র একটি বৈধ JSON অবজেক্ট রিটার্ন করুন:
    {
      "title": "ডায়েট প্ল্যানের নাম (বাংলায়)",
      "description": "সংক্ষিপ্ত বিবরণ (বাংলায়)",
      "meals": [
        {
          "time": "সকালের নাস্তা/দুপুরের খাবার/রাতের খাবার/হালকা নাস্তা",
          "suggestion": "খাবারের প্রস্তাবনা (বাংলায়)",
          "recipeLink": "",
          "calories": "আনুপাতিক ক্যালোরি"
        }
      ],
      "generalAdvice": ["পরামর্শ ১ (বাংলায়)", "পরামর্শ ২ (বাংলায়)"],
      "restrictions": ["নিষেধাজ্ঞা ১ (বাংলায়)", "নিষেধাজ্ঞা ২ (বাংলায়)"]
    }
    ''';

    try {
      final response = await _aiService.getCompletion(prompt);
      
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        final Map<String, dynamic> data = jsonDecode(jsonString);
        return DietPlan.fromJson(data);
      }
      
      throw Exception("Could not parse AI response");
    } catch (e) {
      throw Exception("Failed to generate diet plan: $e");
    }
  }
}
