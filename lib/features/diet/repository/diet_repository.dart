import '../models/diet_plan.dart';

abstract class DietRepository {
  Future<DietPlan> generateDietPlan({
    required int age,
    required String gender,
    required String symptoms,
    required String healthStatus,
    required List<String> preferences,
    required List<String> restrictions,
  });
}
