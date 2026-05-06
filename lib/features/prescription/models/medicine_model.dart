class MedicineModel {
  final String name;
  final String usage;
  final String sideEffects;
  final String warning;
  final String? dosage;
  final List<String>? schedule; // e.g., ["Morning", "Night"]
  final String? relationToFood; // e.g., "Before Meal", "After Meal"
  final int? durationDays;
  final int? stockQuantity;

  const MedicineModel({
    required this.name,
    required this.usage,
    required this.sideEffects,
    required this.warning,
    this.dosage,
    this.schedule,
    this.relationToFood,
    this.durationDays,
    this.stockQuantity,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      name: json['name'] as String,
      usage: json['usage'] as String,
      sideEffects: json['sideEffects'] as String,
      warning: json['warning'] as String,
      dosage: json['dosage'] as String?,
      schedule: (json['schedule'] as List<dynamic>?)?.map((e) => e as String).toList(),
      relationToFood: json['relationToFood'] as String?,
      durationDays: json['durationDays'] as int?,
      stockQuantity: json['stockQuantity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'usage': usage,
      'sideEffects': sideEffects,
      'warning': warning,
      'dosage': dosage,
      'schedule': schedule,
      'relationToFood': relationToFood,
      'durationDays': durationDays,
      'stockQuantity': stockQuantity,
    };
  }
}
