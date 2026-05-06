class UserProgress {
  final int totalPoints;
  final int medicineStreak;
  final int stepStreak;
  final int waterStreak;
  final int loginStreak;
  final int moodStreak;
  final List<String> earnedBadges;
  final DateTime lastMedicineDate;
  final DateTime lastStepDate;
  final DateTime lastWaterDate;
  final DateTime lastLoginDate;
  final DateTime lastMoodDate;

  UserProgress({
    required this.totalPoints,
    required this.medicineStreak,
    required this.stepStreak,
    required this.waterStreak,
    required this.loginStreak,
    required this.moodStreak,
    required this.earnedBadges,
    required this.lastMedicineDate,
    required this.lastStepDate,
    required this.lastWaterDate,
    required this.lastLoginDate,
    required this.lastMoodDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'medicineStreak': medicineStreak,
      'stepStreak': stepStreak,
      'waterStreak': waterStreak,
      'loginStreak': loginStreak,
      'moodStreak': moodStreak,
      'earnedBadges': earnedBadges,
      'lastMedicineDate': lastMedicineDate.toIso8601String(),
      'lastStepDate': lastStepDate.toIso8601String(),
      'lastWaterDate': lastWaterDate.toIso8601String(),
      'lastLoginDate': lastLoginDate.toIso8601String(),
      'lastMoodDate': lastMoodDate.toIso8601String(),
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
    return UserProgress(
      totalPoints: json['totalPoints'] as int? ?? 0,
      medicineStreak: json['medicineStreak'] as int? ?? 0,
      stepStreak: json['stepStreak'] as int? ?? 0,
      waterStreak: json['waterStreak'] as int? ?? 0,
      loginStreak: json['loginStreak'] as int? ?? 0,
      moodStreak: json['moodStreak'] as int? ?? 0,
      earnedBadges: List<String>.from(json['earnedBadges'] as List? ?? []),
      lastMedicineDate: DateTime.parse(json['lastMedicineDate'] as String? ?? yesterday),
      lastStepDate: DateTime.parse(json['lastStepDate'] as String? ?? yesterday),
      lastWaterDate: DateTime.parse(json['lastWaterDate'] as String? ?? yesterday),
      lastLoginDate: DateTime.parse(json['lastLoginDate'] as String? ?? yesterday),
      lastMoodDate: DateTime.parse(json['lastMoodDate'] as String? ?? yesterday),
    );
  }

  factory UserProgress.initial() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return UserProgress(
      totalPoints: 0,
      medicineStreak: 0,
      stepStreak: 0,
      waterStreak: 0,
      loginStreak: 0,
      moodStreak: 0,
      earnedBadges: [],
      lastMedicineDate: yesterday,
      lastStepDate: yesterday,
      lastWaterDate: yesterday,
      lastLoginDate: yesterday,
      lastMoodDate: yesterday,
    );
  }

  UserProgress copyWith({
    int? totalPoints,
    int? medicineStreak,
    int? stepStreak,
    int? waterStreak,
    int? loginStreak,
    int? moodStreak,
    List<String>? earnedBadges,
    DateTime? lastMedicineDate,
    DateTime? lastStepDate,
    DateTime? lastWaterDate,
    DateTime? lastLoginDate,
    DateTime? lastMoodDate,
  }) {
    return UserProgress(
      totalPoints: totalPoints ?? this.totalPoints,
      medicineStreak: medicineStreak ?? this.medicineStreak,
      stepStreak: stepStreak ?? this.stepStreak,
      waterStreak: waterStreak ?? this.waterStreak,
      loginStreak: loginStreak ?? this.loginStreak,
      moodStreak: moodStreak ?? this.moodStreak,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      lastMedicineDate: lastMedicineDate ?? this.lastMedicineDate,
      lastStepDate: lastStepDate ?? this.lastStepDate,
      lastWaterDate: lastWaterDate ?? this.lastWaterDate,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      lastMoodDate: lastMoodDate ?? this.lastMoodDate,
    );
  }
}
