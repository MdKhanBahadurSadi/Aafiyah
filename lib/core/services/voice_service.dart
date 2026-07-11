import 'package:flutter/foundation.dart';

class VoiceService extends ChangeNotifier {
  bool _isListening = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  Future<void> startListening(Function(String) onResult) async {
    _isListening = true;
    notifyListeners();

    // Simulate voice recognition for demo / science fest stability
    await Future.delayed(const Duration(seconds: 2));
    _lastWords = "Amar matha betha korche ebong sharir gorom lagche"; // Sample voice query in Bangla/English
    onResult(_lastWords);

    _isListening = false;
    notifyListeners();
  }

  void stopListening() {
    _isListening = false;
    notifyListeners();
  }
}
