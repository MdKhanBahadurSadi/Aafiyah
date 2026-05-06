import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/app_config.dart';

class AIService {
  late final GenerativeModel _model;

  static const String _systemInstruction = '''
You are "Aafi", a virtual health and well-being assistant for the Aafiyah app. 
Your behavior and tone should be that of a practicing Muslim:
1. Start conversations with "Assalamu Alaikum" (if appropriate for the context).
2. Use phrases like "InshaAllah" (God willing), "Alhamdulillah" (Praise be to God), and "SubhanAllah" (Glory be to God) naturally in conversation.
3. Be extremely polite, humble, and empathetic.
4. Provide advice that is helpful and aligns with Islamic ethics and health principles (e.g., cleanliness, moderation in eating, importance of physical and mental well-veing).
5. If someone asks for medical advice, always remind them that you are an AI assistant and they should consult a qualified doctor, adding "May Allah grant you shifa (healing)."
6. Maintain a respectful and professional boundary.
7. Your goal is to help users achieve "Aafiyah" (complete well-being in this life and the hereafter).
8. When analyzing lab reports, explain the findings in simple, easy-to-understand Bengali (বাংলা) for common people. Use bullet points if necessary.
''';

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-3.1-flash-lite-preview',
      apiKey: AppConfig.geminiApiKey,
      systemInstruction: Content.system(_systemInstruction),
    );
  }

  Future<String> getCompletion(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response from AI.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> getFirstAidGuide(String emergencyType) async {
    final prompt = '''
    The user is facing a medical emergency: $emergencyType.
    Provide immediate, step-by-step first aid instructions in Bengali (বাংলা).
    Keep it concise, clear, and easy to follow during a crisis.
    Start with "Bismillah" and remind them to call emergency services (like 999) if needed.
    Include what NOT to do as well.
    ''';
    return getCompletion(prompt);
  }

  Future<String> analyzeImage(String prompt, File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', bytes),
        ]),
      ];
      final response = await _model.generateContent(content);
      return response.text ?? 'Could not analyze image.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> analyzeLabReport(File imageFile) async {
    const prompt = '''
Please analyze this lab report image. 
1. Identify the key tests performed.
2. Explain the results in simple Bengali (বাংলা) that a non-medical person can understand.
3. Highlight any values that are outside the normal range.
4. Provide general wellness advice based on the results (e.g., diet, lifestyle).
5. Always include a disclaimer that this is not a professional medical diagnosis and they should consult a doctor.
''';
    return analyzeImage(prompt, imageFile);
  }
}
