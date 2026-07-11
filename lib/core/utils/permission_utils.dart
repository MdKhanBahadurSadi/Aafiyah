import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/permission_disclosure_dialog.dart';

class PermissionUtils {
  static Future<bool> requestLocationPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      final bool? agreed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PermissionDisclosureDialog(
          title: 'Location Access',
          icon: Icons.location_on_rounded,
          message: 'Aafiyah uses your location to find nearby doctors, hospitals, and pharmacies, and to provide location-specific health alerts. This information is used only while you are using the app.',
        ),
      );

      if (agreed == true) {
        permission = await Geolocator.requestPermission();
      } else {
        return false;
      }
    }
    
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }
}
