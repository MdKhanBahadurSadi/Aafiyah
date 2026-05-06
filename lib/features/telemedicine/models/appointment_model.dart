import 'doctor_model.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

class AppointmentModel {
  final String id;
  final String doctorId;
  final String userId;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String reason;
  final DoctorModel? doctor; // Optional: include doctor details if needed

  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.dateTime,
    required this.status,
    required this.reason,
    this.doctor,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      userId: json['userId'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'userId': userId,
      'dateTime': dateTime.toIso8601String(),
      'status': status.name,
      'reason': reason,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? userId,
    DateTime? dateTime,
    AppointmentStatus? status,
    String? reason,
    DoctorModel? doctor,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      userId: userId ?? this.userId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      doctor: doctor ?? this.doctor,
    );
  }
}
