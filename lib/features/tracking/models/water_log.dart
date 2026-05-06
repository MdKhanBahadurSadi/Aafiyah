class WaterLog {
  final DateTime date;
  final int amountMl;

  const WaterLog({
    required this.date,
    required this.amountMl,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'amountMl': amountMl,
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      date: DateTime.parse(map['date']),
      amountMl: map['amountMl'],
    );
  }
}
