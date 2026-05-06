import '../models/symptom_request.dart';
import '../models/symptom_response.dart';

abstract class SymptomRepository {
  Future<SymptomResponse> getAdvice(SymptomRequest request);
}
