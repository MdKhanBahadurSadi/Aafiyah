import 'package:flutter/material.dart';
import 'package:aafiyah/features/symptom/models/symptom_request.dart';
import 'package:aafiyah/features/symptom/models/symptom_response.dart';
import 'package:aafiyah/features/symptom/repository/symptom_repository.dart';
import 'package:aafiyah/features/symptom/repository/symptom_repository_impl.dart';
import 'package:aafiyah/core/state/app_state.dart';
import 'package:aafiyah/core/utils/emergency_keywords.dart';

class SymptomState extends ChangeNotifier {
  final SymptomRepository _repository = SymptomRepositoryImpl();
  SymptomResponse? _response;

  SymptomResponse? get response => _response;

  Future<void> submitSymptom(SymptomRequest request, AppState appState) async {
    appState.setLoading(true);
    appState.clearError();
    try {
      if (detectEmergency(request.symptom)) {
        _response = const SymptomResponse(
          advice: "Seek immediate medical attention. Your symptoms indicate a potential medical emergency.",
          severity: "Urgent",
          emergency: true,
          seeDoctor: true,
        );
      } else {
        _response = await _repository.getAdvice(request);
      }
      notifyListeners();
    } catch (e) {
      appState.setError("Failed to get analysis: ${e.toString()}");
    } finally {
      appState.setLoading(false);
    }
  }
}
