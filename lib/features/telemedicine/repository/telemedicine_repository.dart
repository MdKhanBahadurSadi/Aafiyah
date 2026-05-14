import '../models/doctor_model.dart';
import '../models/appointment_model.dart';

abstract class TelemedicineRepository {
  Stream<List<DoctorModel>> getDoctors();
  Future<void> bookAppointment(AppointmentModel appointment);
  Stream<List<AppointmentModel>> getUserAppointments(String userId);
}
