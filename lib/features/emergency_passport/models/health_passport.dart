class HealthPassport {
  final String fullName;
  final String bloodGroup;
  final List<String> allergies;
  final List<String> chronicConditions;
  final String emergencyContactName;
  final String emergencyContactPhone;

  HealthPassport({
    required this.fullName,
    required this.bloodGroup,
    required this.allergies,
    required this.chronicConditions,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
  });

  String toQrData() {
    return '''
NAME: $fullName
BLOOD: $bloodGroup
ALLERGIES: ${allergies.join(', ')}
CONDITIONS: ${chronicConditions.join(', ')}
EMERGENCY CONTACT: $emergencyContactName ($emergencyContactPhone)
''';
  }
}
