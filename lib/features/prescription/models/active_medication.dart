import 'medicine_model.dart';

class ActiveMedication {
  final String id;
  final MedicineModel medicine;
  final DateTime startDate;
  int remainingStock;
  final List<int> reminderIds;

  ActiveMedication({
    required this.id,
    required this.medicine,
    required this.startDate,
    required this.remainingStock,
    required this.reminderIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicine': medicine.toJson(),
      'startDate': startDate.toIso8601String(),
      'remainingStock': remainingStock,
      'reminderIds': reminderIds,
    };
  }

  factory ActiveMedication.fromJson(Map<String, dynamic> json) {
    return ActiveMedication(
      id: json['id'] as String,
      medicine: MedicineModel.fromJson(json['medicine'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      remainingStock: json['remainingStock'] as int,
      reminderIds: List<int>.from(json['reminderIds'] as List),
    );
  }
}
