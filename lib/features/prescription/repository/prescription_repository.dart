import 'package:aafiyah/features/prescription/models/medicine_model.dart';

abstract class PrescriptionRepository {
  Future<List<MedicineModel>> analyzePrescription(String imagePath);
}
