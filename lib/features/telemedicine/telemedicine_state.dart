import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/state/app_state.dart';
import '../../core/services/ai_service.dart';
import 'models/doctor_model.dart';
import 'models/appointment_model.dart';
import 'repository/telemedicine_repository.dart';
import 'repository/telemedicine_repository_impl.dart';

class TelemedicineState extends ChangeNotifier {
  final TelemedicineRepository _repository = TelemedicineRepositoryImpl();
  final AIService _aiService = AIService();
  List<DoctorModel> _doctors = [];
  List<AppointmentModel> _appointments = [];
  StreamSubscription? _doctorsSubscription;
  StreamSubscription? _appointmentsSubscription;
  String _aiSuggestion = '';

  List<DoctorModel> get doctors => _doctors;
  List<AppointmentModel> get appointments => _appointments;
  String get aiSuggestion => _aiSuggestion;

  void fetchDoctors(AppState appState) {
    _doctorsSubscription?.cancel();
    _doctorsSubscription = _repository.getDoctors().listen(
      (doctorsList) {
        _doctors = doctorsList;
        notifyListeners();
      },
      onError: (e) {
        appState.setError('Failed to fetch doctors');
      },
    );
  }

  Future<void> getSmartSuggestions(String symptoms, AppState appState) async {
    appState.setLoading(true);
    try {
      Position? position;
      try {
        // Check permissions and get current location
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          position = await Geolocator.getCurrentPosition();
        }
      } catch (e) {
        // Location fails silently, AI will still suggest based on symptoms
      }

      _aiSuggestion = await _aiService.suggestDoctors(
        symptoms: symptoms,
        doctors: _doctors,
        userLat: position?.latitude,
        userLon: position?.longitude,
      );
      notifyListeners();
    } catch (e) {
      appState.setError('AI Suggestion failed');
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doctorId: doctorId,
        userId: userId,
        dateTime: dateTime,
        status: AppointmentStatus.pending,
        reason: reason,
      );
      await _repository.bookAppointment(appointment);
    } catch (e) {
      appState.setError('Failed to book appointment');
    } finally {
      appState.setLoading(false);
    }
  }

  void fetchAppointments(String userId, AppState appState) {
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription = _repository.getUserAppointments(userId).listen(
      (appointmentsList) {
        _appointments = appointmentsList;
        notifyListeners();
      },
      onError: (e) {
        appState.setError('Failed to fetch appointments');
      },
    );
  }

  @override
  void dispose() {
    _doctorsSubscription?.cancel();
    _appointmentsSubscription?.cancel();
    super.dispose();
  }
}
