import 'dart:convert';
import 'dart:io';
import '../../../core/services/ai_service.dart';
import 'package:aafiyah/features/prescription/repository/prescription_repository.dart';
import 'package:aafiyah/features/prescription/models/medicine_model.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final AIService _aiService = AIService();

  @override
  Future<List<MedicineModel>> analyzePrescription(String imagePath) async {
    const prompt = '''
    এই প্রেসক্রিপশনের ছবিটি পরীক্ষা করুন এবং সমস্ত ওষুধের বিস্তারিত তথ্য বের করুন:
    ১. ওষুধের নাম (Medicine Name)
    ২. সাধারণ ব্যবহার ও উদ্দেশ্য (usage)
    ৩. সম্ভাব্য পার্শ্বপ্রতিক্রিয়া (sideEffects)
    ৪. জরুরি সতর্কতা (warning)
    ৫. সেবনের মাত্রা (dosage, যেমন: "১টি ট্যাবলেট", "৫ মি.লি.")
    ৬. খাওয়ার সময়সূচী (schedule, যেমন: ["সকাল", "রাত"], ["৮ ঘণ্টা পর পর"])
    ৭. খাবারের সাথে সম্পর্ক (relationToFood, যেমন: "খাওয়ার আগে", "খাওয়ার পরে", "খাবারের সাথে")
    ৮. মেয়াদকাল বা দিন সংখ্যা (durationDays, যেমন: 7)
    ৯. প্রাথমিক মজুত পরিমাণ (stockQuantity)
    
    বাধ্যতামূলক নিয়ম (STRICT REQUIREMENT):
    "usage", "sideEffects", "warning", "dosage", "schedule", "relationToFood" - এই সমস্ত ফিল্ডের ভ্যালু ১০০% অবশ্যই স্পষ্ট, সহজ এবং শুদ্ধ বাংলা ভাষায় (বাংলা বর্ণমালায়) হতে হবে। কোনো ইংরেজি বাক্য থাকবে না।
    
    শুধুমাত্র নিচের ফরম্যাটে একটি বৈধ JSON অ্যারে রিটার্ন করুন:
    [
      {
        "name": "Medicine Name",
        "usage": "ওষুধের ব্যবহার (বাংলায়)",
        "sideEffects": "পার্শ্বপ্রতিক্রিয়া (বাংলায়)",
        "warning": "সতর্কতা (বাংলায়)",
        "dosage": "১টি ট্যাবলেট",
        "schedule": ["সকাল", "রাত"],
        "relationToFood": "খাওয়ার পরে",
        "durationDays": 7,
        "stockQuantity": 14
      }
    ]
    
    কোনো ওষুধ পাওয়া না গেলে খালি অ্যারে [] রিটার্ন করুন।
    ''';

    try {
      final response = await _aiService.analyzeImage(prompt, File(imagePath));
      
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        final List<dynamic> data = jsonDecode(jsonString);
        return data.map((item) => MedicineModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      print("Error analyzing prescription: $e");
      return [];
    }
  }
}
