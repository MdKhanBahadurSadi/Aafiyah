import 'dart:convert';
import 'dart:io';
import '../../../core/services/ai_service.dart';
import '../../prescription/models/medicine_model.dart';
import 'pill_repository.dart';

class PillRepositoryImpl implements PillRepository {
  final AIService _aiService = AIService();

  @override
  Future<MedicineModel?> identifyPill(File imageFile) async {
    const prompt = '''
    ছবিটি (পিল, ট্যাবলেট, ক্যাপসুল বা ওষুধের স্ট্রিপ) খুব ভালোভাবে দেখে ওষুধটি শনাক্ত করুন।
    ওষুধের নাম, জেনোটাইপ বা ব্র্যান্ড বোঝা গেলে তা নিখুঁতভাবে বের করুন।
    
    বাধ্যতামূলক নিয়মাবলী (CRITICAL MANDATORY REQUIREMENTS):
    ১. সমস্ত তথ্য ও ফিল্ড সম্পূর্ণ বাংলা ভাষায় (বাংলা বর্ণমালায়) প্রদান করতে হবে।
    ২. "name" ফিল্ডে ওষুধের নাম বাংলা ও ইংরেজিতে লিখুন (যেমন: মেট্রোনিডাজল ট্যাবলেট ৪০০ মি.গ্রা. / Metronidazole 400 mg)।
    ৩. "usage" (ব্যবহার), "sideEffects" (পার্শ্বপ্রতিক্রিয়া), এবং "warning" (জরুরি সতর্কতা) - এই ৩টি ফিল্ডের উত্তর ১০০% বাধ্যতামূলকভাবে স্পষ্ট, সাবলীল এবং সহজ বাংলা ভাষায় হতে হবে। কোনো ইংরেজি বাক্য বা প্যারাগ্রাফ দেওয়া যাবে না।
    
    শুধুমাত্র নিচের ফরম্যাটে একটি বৈধ JSON অবজেক্ট রিটার্ন করুন:
    {
      "name": "মেট্রোনিডাজল ট্যাবলেট ৪০০ মি.গ্রা. (Metronidazole 400 mg)",
      "usage": "ওষুধের ব্যবহার এবং কার্যকারিতা (সম্পূর্ণ বাংলা ভাষায়)",
      "sideEffects": "পার্শ্বপ্রতিক্রিয়া (সম্পূর্ণ বাংলা ভাষায়)",
      "warning": "জরুরি সতর্কতা (সম্পূর্ণ বাংলা ভাষায়)"
    }
    
    যদি ছবিটি ওষুধের না হয় বা চেনা না যায়, তবে null রিটার্ন করুন।
    ''';

    try {
      final response = await _aiService.analyzeImage(prompt, imageFile);
      
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        final Map<String, dynamic> data = jsonDecode(jsonString);
        return MedicineModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print("Error identifying pill: $e");
      return null;
    }
  }
}
