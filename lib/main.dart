import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/state/app_state.dart';
import 'features/auth/auth_state.dart';
import 'features/home/home_state.dart';
import 'features/symptom/symptom_state.dart';
import 'features/prescription/prescription_state.dart';
import 'features/tracking/tracking_state.dart';
import 'features/diet/diet_state.dart';
import 'features/mental_health/mental_health_state.dart';
import 'features/pill_identification/pill_state.dart';
import 'features/lab_report/lab_report_state.dart';
import 'features/telemedicine/telemedicine_state.dart';
import 'features/gamification/gamification_state.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Notification Service
  await NotificationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => HomeState()),
        ChangeNotifierProvider(create: (_) => SymptomState()),
        ChangeNotifierProvider(create: (_) => PrescriptionState()),
        ChangeNotifierProvider(create: (_) => TrackingState()),
        ChangeNotifierProvider(create: (_) => DietState()),
        ChangeNotifierProvider(create: (_) => MentalHealthState()),
        ChangeNotifierProvider(create: (_) => PillState()),
        ChangeNotifierProvider(create: (_) => LabReportState()),
        ChangeNotifierProvider(create: (_) => TelemedicineState()),
        ChangeNotifierProvider(create: (_) => GamificationState()),
      ],
      child: const AafiyahApp(),
    ),
  );
}
