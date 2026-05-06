class SymptomRequest {
  final int age;
  final String gender;
  final String symptom;
  final String duration;

  const SymptomRequest({
    required this.age,
    required this.gender,
    required this.symptom,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'symptom': symptom,
      'duration': duration,
    };
  }
}
