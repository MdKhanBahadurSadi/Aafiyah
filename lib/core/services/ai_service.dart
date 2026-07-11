import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/app_config.dart';
import '../../features/telemedicine/models/doctor_model.dart';

class AIService {
  late final GenerativeModel _model;
// ... (keep existing _systemInstruction)

  static const String _systemInstruction = '''
You are "Aafi", a virtual health and well-being assistant for the Aafiyah app. 
Your behavior and tone should be that of a practicing Muslim:
1. MANDATORY: ALWAYS respond strictly, completely, and exclusively in clear, empathetic, easy-to-understand Bengali (বাংলা বর্ণমালায়) for ALL user messages, pill identifications, lab report analyses, prescription analyses, and health queries. NEVER output responses in English.
2. Start conversations with "Assalamu Alaikum" (আসসালামু আলাইকুম).
3. Use phrases like "InshaAllah" (ইনশাআল্লাহ), "Alhamdulillah" (আলহামদুলিল্লাহ), and "SubhanAllah" (সুবহানআল্লাহ) naturally in conversation.
4. Be extremely polite, humble, and empathetic.
5. Provide advice that is helpful and aligns with Islamic ethics and health principles (e.g., cleanliness, moderation in eating, importance of physical and mental well-being).
6. If someone asks for medical advice, always remind them in Bengali that you are an AI assistant and they should consult a qualified doctor, adding "আল্লাহ আপনাকে শেফা দান করুন।"
7. Maintain a respectful and professional boundary.
8. Your goal is to help users achieve "Aafiyah" (complete well-being in this life and the hereafter).
''';

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppConfig.geminiApiKey,
      systemInstruction: Content.system(_systemInstruction),
    );
  }

  Future<String> getCompletion(String prompt) async {
    if (AppConfig.geminiApiKey.isEmpty) {
      return 'API Key পাওয়া যায়নি!\n\nঅনুগ্রহ করে অ্যাপ রান করার সময় --dart-define=GEMINI_API_KEY=YOUR_KEY ব্যবহার করুন অথবা app_config.dart ফাইলে API Key সেট করুন।';
    }
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'AI থেকে কোনো উত্তর পাওয়া যায়নি।';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> getFirstAidGuide(String emergencyType) async {
    final prompt = '''
    জরুরি চিকিৎসা পরিস্থিতি: $emergencyType
    এই মুহূর্তে কী কী প্রাথমিক চিকিৎসা নেওয়া উচিত তা ধাপে ধাপে সহজ বাংলা ভাষায় (বাংলা বর্ণমালায়) প্রদান করুন।
    সংক্ষিপ্ত, স্পষ্ট এবং সহজে অনুসরণযোগ্য করুন।
    "বিসমিল্লাহ" দিয়ে শুরু করুন এবং প্রয়োজনে জরুরি সেবা (যেমন ৯৯৯) ডায়াল করতে মনে করিয়ে দিন।
    কী কী করা যাবে না (What NOT to do) তাও উল্লেখ করুন।
    উত্তরটি অবশ্যই সম্পূর্ণ বাংলা ভাষায় হতে হবে।
    ''';
    return getCompletion(prompt);
  }

  Future<String> analyzeImage(String prompt, File imageFile) async {
    if (AppConfig.geminiApiKey.isEmpty) {
      return 'API Key পাওয়া যায়নি!\n\nঅনুগ্রহ করে অ্যাপ রান করার সময় --dart-define=GEMINI_API_KEY=YOUR_KEY ব্যবহার করুন অথবা app_config.dart ফাইলে API Key সেট করুন।';
    }
    try {
      final bytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ]),
      ];
      final response = await _model.generateContent(content);
      return response.text ?? 'ছবিটি বিশ্লেষণ করা সম্ভব হয়নি।';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> analyzeLabReport(File imageFile) async {
    const prompt = '''
এই ল্যাব রিপোর্ট ছবিটি ভালোভাবে পর্যবেক্ষণ ও বিশ্লেষণ করুন:
১. যেসব পরীক্ষা (tests) করা হয়েছে তা উল্লেখ করুন।
২. পরীক্ষার ফলাফলগুলো সাধারণ মানুষের সহজে বোঝার মতো স্পষ্ট বাংলা ভাষায় (বাংলা বর্ণমালায়) ব্যাখ্যা করুন।
৩. যে মানগুলো স্বাভাবিক সীমার বাইরে আছে (High/Low) তা বাংলায় উল্লেখ করুন।
৪. উক্ত ফলাফলের ওপর ভিত্তি করে প্রয়োজনীয় স্বাস্থ্য ও জীবনযাত্রার পরামর্শ সম্পূর্ণ বাংলা ভাষায় প্রদান করুন।
৫. শেষে বাংলায় ডিসক্লেইমার দিন যে এটি কোনো ডাক্তারি নির্ণয় নয় এবং অভিজ্ঞ ডাক্তারের পরামর্শ নেওয়া উচিত।

অবশ্যই সম্পূর্ণ উত্তর বাংলায় দিন, কোনো ইংরেজি বাক্য ব্যবহার করবেন না।
''';
    return analyzeImage(prompt, imageFile);
  }

  Future<String> suggestDoctors({
    required String symptoms,
    required List<DoctorModel> doctors,
    double? userLat,
    double? userLon,
  }) async {
    final doctorListString = doctors.map((d) => 
      'Name: ${d.name}, Specialty: ${d.specialty}, Bio: ${d.bio}, Address: ${d.address}'
    ).join('\n');

    final prompt = '''
রোগীর উপসর্গ: "$symptoms"
রোগীর অবস্থান (Lat: $userLat, Lon: $userLon)।
নিচের ডাক্তারের তালিকা থেকে সেরা ২-৩ জন ডাক্তারকে পছন্দ করুন:
$doctorListString

নির্দেশাবলী:
১. উপসর্গের সাথে ডাক্তারের বিশেষজ্ঞতা মেলাবেন।
২. অবস্থান থাকলে নিকটস্থ ডাক্তারদের অগ্রাধিকার দিন।
৩. সমস্ত বক্তব্য বন্ধুভাবাপন্ন ও ইসলামি ভাবধারায় ১০০% সহজ বাংলায় (বাংলা বর্ণমালায়) লিখুন।
৪. কেন এই ডাক্তারদের নির্বাচন করেছেন তা সহজ বাংলায় বুঝিয়ে দিন।
''';
    return getCompletion(prompt);
  }
}
