class AppConfig {
  /// Gemini API Key obtained from dart-define or direct fallback configuration
  static const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Fallback API key for local development (if not using --dart-define)
  static const String _fallbackApiKey = 'YOUR_API_KEY_HERE';

  static String get geminiApiKey =>
      _envApiKey.isNotEmpty ? _envApiKey : _fallbackApiKey;
}
