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
    Generate a daily diet and nutrition plan for a person with the following profile:
    Age: $age
    Gender: $gender
    Symptoms: $symptoms
    Current Health Status: $healthStatus
    Dietary Preferences: ${preferences.join(", ")}
    Dietary Restrictions: ${restrictions.join(", ")}
    
    The plan should be healthy, balanced, and consider Islamic dietary principles (Halal).
    The description and advice should be in Bengali (বাংলা) to make it easy to understand for the user.
    
    Respond ONLY with a valid JSON object in this exact format:
    {
      "title": "Diet Plan Title",
      "description": "Short overview in Bengali",
      "meals": [
        {
          "time": "Breakfast/Lunch/Dinner/Snack",
          "suggestion": "Detailed meal suggestion in Bengali",
          "recipeLink": "Optional recipe link or name",
          "calories": "Approximate calories"
        }
      ],
      "generalAdvice": ["Advice 1 in Bengali", "Advice 2 in Bengali"],
      "restrictions": ["Restriction 1 in Bengali", "Restriction 2 in Bengali"]
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
