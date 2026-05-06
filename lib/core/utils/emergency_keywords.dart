final List<String> emergencyKeywords = [
  'chest pain',
  'unconscious',
  'severe bleeding',
  'difficulty breathing',
  'stroke',
];

bool detectEmergency(String symptom) {
  final normalizedSymptom = symptom.toLowerCase();
  return emergencyKeywords.any((keyword) => normalizedSymptom.contains(keyword));
}
