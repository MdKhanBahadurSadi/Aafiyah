import 'dart:io';
import '../../prescription/models/medicine_model.dart';

abstract class PillRepository {
  Future<MedicineModel?> identifyPill(File imageFile);
}
