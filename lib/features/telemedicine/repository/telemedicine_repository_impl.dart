import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import 'telemedicine_repository.dart';

class TelemedicineRepositoryImpl implements TelemedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<DoctorModel> _mockDoctors = [
    const DoctorModel(
      id: 'doc1',
      name: 'Dr. Murad Hossain',
      specialty: 'General Physician',
      imageUrl: 'https://healtha.io/wp-content/uploads/2025/07/physiotherapist-md-murad-hossain-mehedi-pt-dhaka-photo.webp',
      rating: 4.8,
      reviews: 120,
      bio: 'Expert in primary care with over 10 years of experience.',
      consultationFee: 50.0,
      latitude: 23.7509,
      longitude: 90.3935,
      address: 'Dhanmondi, Dhaka',
    ),
    const DoctorModel(
      id: 'doc2',
      name: 'Dr. Mehedi Hasan',
      specialty: 'Cardiologist',
      imageUrl: 'https://media.licdn.com/dms/image/v2/D5603AQHzID4jQpfi3A/profile-displayphoto-scale_200_200/B56ZlM7zoZKIAY-/0/1757932372459?e=2147483647&v=beta&t=CReHq3Csr8Of2HAeVTcdVsqwo8WS4IW1Gg3ppyULVwQ',
      rating: 4.9,
      reviews: 85,
      bio: 'Specialist in cardiovascular health and preventive medicine.',
      consultationFee: 80.0,
      latitude: 23.7925,
      longitude: 90.4078,
      address: 'Banani, Dhaka',
    ),
    const DoctorModel(
      id: 'doc3',
      name: 'Dr. Mahmudul Haque',
      specialty: 'Pediatrician',
      imageUrl: 'https://www.doctorbangladesh.com/wp-content/uploads/Prof.-Dr.-Mahmudul-Haque.jpg',
      rating: 4.7,
      reviews: 150,
      bio: 'Passionate about child health and developmental care.',
      consultationFee: 60.0,
      latitude: 23.8103,
      longitude: 90.4125,
      address: 'Gulshan, Dhaka',
    ),
  ];

  @override
  Stream<List<DoctorModel>> getDoctors() {
    return _firestore.collection('doctors').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return _mockDoctors;
      return snapshot.docs
          .map((doc) => DoctorModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    }).handleError((_) => _mockDoctors);
  }

  @override
  Future<void> bookAppointment(AppointmentModel appointment) async {
    try {
      await _firestore.collection('appointments').doc(appointment.id).set(appointment.toJson());
    } catch (e) {
      // In a real app, we might handle this differently, but for now we assume it works or fails silently
      rethrow;
    }
  }

  @override
  Stream<List<AppointmentModel>> getUserAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Sort manually because composite index might not be created yet in Firebase
      appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return appointments;
    });
  }
}
