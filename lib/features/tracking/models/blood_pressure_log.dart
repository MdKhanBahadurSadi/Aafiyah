class BloodPressureLog {
  final int systolic;
  final int diastolic;
  final DateTime date;

  const BloodPressureLog({
    required this.systolic,
    required this.diastolic,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'date': date.toIso8601String(),
    };
  }

  factory BloodPressureLog.fromMap(Map<String, dynamic> map) {
    return BloodPressureLog(
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      date: DateTime.parse(map['date']),
    );
  }
}
