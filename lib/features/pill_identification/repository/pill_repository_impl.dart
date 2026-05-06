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
    Identify the medicine from this image (pill, tablet, capsule, or medicine strip). 
    Focus on recognizing the name of the medicine and its brand if visible. 
    Provide information about its common usage, potential side effects, and any critical warnings.
    
    Respond ONLY with a valid JSON object in this exact format:
    {
      "name": "Medicine Name",
      "usage": "Commonly used for...",
      "sideEffects": "Common side effects",
      "warning": "Critical warnings"
    }
    
    If the medicine cannot be identified, return null.
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
