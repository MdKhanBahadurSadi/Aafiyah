import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

abstract class TelemedicineRepository {
  Future<List<DoctorModel>> getDoctors();
  Future<void> bookAppointment(AppointmentModel appointment);
  Future<List<AppointmentModel>> getUserAppointments(String userId);
}
