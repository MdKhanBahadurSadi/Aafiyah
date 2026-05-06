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
    Analyze the following health symptoms and provide advice.
    User Info: Age: ${request.age}, Gender: ${request.gender}.
    Symptoms: ${request.symptom} for ${request.duration}.
    
    Respond ONLY with a valid JSON object in this format:
    {
      "advice": "Detailed health advice string here",
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
        advice: "Sorry, I couldn't analyze your symptoms right now. Please consult a doctor if you feel unwell.",
        severity: "Unknown",
        emergency: false,
        seeDoctor: true,
      );
    }
  }
}
