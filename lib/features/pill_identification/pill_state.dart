import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/state/app_state.dart';
import '../prescription/models/medicine_model.dart';
import 'repository/pill_repository.dart';
import 'repository/pill_repository_impl.dart';

class PillState extends ChangeNotifier {
  final PillRepository _repository = PillRepositoryImpl();
  MedicineModel? _identifiedPill;
  File? _pillImage;

  MedicineModel? get identifiedPill => _identifiedPill;
  File? get pillImage => _pillImage;

  void setPillImage(File image) {
    _pillImage = image;
    _identifiedPill = null;
    notifyListeners();
  }

  Future<void> identify(AppState appState) async {
    if (_pillImage == null) {
      appState.setError("Please capture or select a pill image first.");
      return;
    }

    appState.setLoading(true);
    appState.clearError();
    try {
      _identifiedPill = await _repository.identifyPill(_pillImage!);
      if (_identifiedPill == null) {
        appState.setError("Could not identify this medicine. Please ensure the brand name is visible.");
      }
      notifyListeners();
    } catch (e) {
      appState.setError("Identification failed: ${e.toString()}");
    } finally {
      appState.setLoading(false);
    }
  }

  void reset() {
    _pillImage = null;
    _identifiedPill = null;
    notifyListeners();
  }
}
