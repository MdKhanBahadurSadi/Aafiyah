import 'package:flutter/material.dart';
import '../../core/state/app_state.dart';
import 'models/diet_plan.dart';
import 'repository/diet_repository.dart';
import 'repository/diet_repository_impl.dart';

class DietState extends ChangeNotifier {
  final DietRepository _repository = DietRepositoryImpl();
  DietPlan? _dietPlan;

  DietPlan? get dietPlan => _dietPlan;

  Future<void> generatePlan({
    required int age,
    required String gender,
    required String symptoms,
    required String healthStatus,
    required List<String> preferences,
    required List<String> restrictions,
    required AppState appState,
  }) async {
    appState.setLoading(true);
    appState.clearError();
    try {
      _dietPlan = await _repository.generateDietPlan(
        age: age,
        gender: gender,
        symptoms: symptoms,
        healthStatus: healthStatus,
        preferences: preferences,
        restrictions: restrictions,
      );
      notifyListeners();
    } catch (e) {
      appState.setError("Failed to generate diet plan: ${e.toString()}");
    } finally {
      appState.setLoading(false);
    }
  }

  void clearPlan() {
    _dietPlan = null;
    notifyListeners();
  }
}
