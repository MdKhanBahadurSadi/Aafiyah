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
    Analyze this prescription image and extract all medicines. 
    Focus on finding:
    1. Medicine Name
    2. General usage/purpose
    3. Potential side effects
    4. Critical warnings
    5. Dosage (e.g., "1 tablet", "5ml")
    6. Schedule (e.g., ["Morning", "Night"], ["Every 8 hours"])
    7. Relation to food (e.g., "Before Meal", "After Meal", "With Meal")
    8. Duration in days (e.g., 7)
    9. Initial stock quantity if mentioned, otherwise estimate based on duration and schedule.
    
    Respond ONLY with a valid JSON array of objects in this exact format:
    [
      {
        "name": "Medicine Name",
        "usage": "Usage instructions",
        "sideEffects": "Side effects",
        "warning": "Warnings",
        "dosage": "1 tablet",
        "schedule": ["Morning", "Night"],
        "relationToFood": "After Meal",
        "durationDays": 7,
        "stockQuantity": 14
      }
    ]
    
    If no medicines are found, return an empty array [].
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
