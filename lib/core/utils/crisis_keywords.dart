final List<String> crisisKeywords = [
  'suicide',
  'kill myself',
  'want to die',
  'end my life',
  'hopeless',
  'hurt myself',
  'no reason to live',
  'better off dead',
];

bool detectCrisis(String text) {
  final normalized = text.toLowerCase();
  return crisisKeywords.any((keyword) => normalized.contains(keyword));
}
