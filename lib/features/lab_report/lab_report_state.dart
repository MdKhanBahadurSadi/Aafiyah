import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/services/ai_service.dart';

class LabReportState extends ChangeNotifier {
  final AIService _aiService = AIService();

  File? _selectedImage;
  String? _analysisResult;
  bool _isLoading = false;

  File? get selectedImage => _selectedImage;
  String? get analysisResult => _analysisResult;
  bool get isLoading => _isLoading;

  void setImage(File image) {
    _selectedImage = image;
    _analysisResult = null;
    notifyListeners();
  }

  Future<void> analyzeReport() async {
    if (_selectedImage == null) return;

    _isLoading = true;
    _analysisResult = null;
    notifyListeners();

    try {
      _analysisResult = await _aiService.analyzeLabReport(_selectedImage!);
    } catch (e) {
      _analysisResult = 'Error analyzing report: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _selectedImage = null;
    _analysisResult = null;
    _isLoading = false;
    notifyListeners();
  }
}
