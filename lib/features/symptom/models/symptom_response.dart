class SymptomResponse {
  final String advice;
  final String severity;
  final bool emergency;
  final bool seeDoctor;

  const SymptomResponse({
    required this.advice,
    required this.severity,
    required this.emergency,
    required this.seeDoctor,
  });

  factory SymptomResponse.fromJson(Map<String, dynamic> json) {
    return SymptomResponse(
      advice: json['advice'] as String,
      severity: json['severity'] as String,
      emergency: json['emergency'] as bool,
      seeDoctor: json['seeDoctor'] as bool,
    );
  }
}
