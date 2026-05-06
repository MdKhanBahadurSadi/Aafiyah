class HealthData {
  final int steps;
  final double heartRate;
  final double sleepHours;
  final DateTime date;

  HealthData({
    required this.steps,
    required this.heartRate,
    required this.sleepHours,
    required this.date,
  });

  factory HealthData.empty() {
    return HealthData(
      steps: 0,
      heartRate: 0,
      sleepHours: 0,
      date: DateTime.now(),
    );
  }
}
