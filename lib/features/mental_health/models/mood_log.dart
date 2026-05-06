class MoodLog {
  final String id;
  final DateTime date;
  final String mood; // e.g., "Happy", "Sad", "Anxious", "Neutral", "Angry"
  final String? note;

  MoodLog({
    required this.id,
    required this.date,
    required this.mood,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'note': note,
    };
  }

  factory MoodLog.fromJson(Map<String, dynamic> json) {
    return MoodLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String,
      note: json['note'] as String?,
    );
  }
}
