import 'package:flutter/material.dart';
import '../../core/state/app_state.dart';
import 'models/doctor_model.dart';
import 'models/appointment_model.dart';
import 'repository/telemedicine_repository.dart';
import 'repository/telemedicine_repository_impl.dart';

class TelemedicineState extends ChangeNotifier {
  final TelemedicineRepository _repository = TelemedicineRepositoryImpl();
  List<DoctorModel> _doctors = [];
  List<AppointmentModel> _appointments = [];

  List<DoctorModel> get doctors => _doctors;
  List<AppointmentModel> get appointments => _appointments;

  Future<void> fetchDoctors(AppState appState) async {
    appState.setLoading(true);
    try {
      _doctors = await _repository.getDoctors();
      notifyListeners();
    } catch (e) {
      appState.setError('Failed to fetch doctors');
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> bookAppointment({
    required String doctorId,
    required String userId,
    required DateTime dateTime,
    required String reason,
    required AppState appState,
  }) async {
    appState.setLoading(true);
    try {
      final appointment = AppointmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID
        doctorId: doctorId,
        userId: userId,
        dateTime: dateTime,
        status: AppointmentStatus.pending,
        reason: reason,
      );
      await _repository.bookAppointment(appointment);
      await fetchAppointments(userId, appState);
    } catch (e) {
      appState.setError('Failed to book appointment');
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> fetchAppointments(String userId, AppState appState) async {
    appState.setLoading(true);
    try {
      _appointments = await _repository.getUserAppointments(userId);
      notifyListeners();
    } catch (e) {
      appState.setError('Failed to fetch appointments');
    } finally {
      appState.setLoading(false);
    }
  }
}
