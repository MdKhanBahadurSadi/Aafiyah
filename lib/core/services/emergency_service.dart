import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  Future<void> sendSOS() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contact = prefs.getString('emergency_contact');
    
    if (contact == null || contact.isEmpty) return;

    final position = await getCurrentLocation();
    String message = "EMERGENCY! I need help.";
    if (position != null) {
      message += " My location: https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
    }

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: contact,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  Future<void> saveEmergencyContact(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_contact', number);
  }

  Future<String?> getEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('emergency_contact');
  }
}
