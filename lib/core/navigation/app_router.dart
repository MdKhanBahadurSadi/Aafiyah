import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/symptom/presentation/pages/symptom_screen.dart';
import '../../features/symptom/presentation/pages/advice_result_screen.dart';
import '../../features/symptom/presentation/pages/emergency_alert_screen.dart';
import '../../features/prescription/presentation/pages/prescription_upload_screen.dart';
import '../../features/prescription/presentation/pages/medicine_detail_screen.dart';
import '../../features/tracking/presentation/pages/water_tracker_screen.dart';
import '../../features/tracking/presentation/pages/bmi_screen.dart';
import '../../features/tracking/presentation/pages/blood_pressure_screen.dart';
import '../../features/tracking/presentation/pages/wearable_screen.dart';
import '../../features/ai_agent/presentation/pages/ai_chat_screen.dart';
import '../../features/lab_report/presentation/pages/lab_report_screen.dart';
import '../../features/diet/presentation/pages/diet_planner_screen.dart';
import '../../features/diet/presentation/pages/diet_result_screen.dart';
import '../../features/pill_identification/presentation/pages/pill_identification_screen.dart';
import '../../features/mental_health/presentation/pages/mood_journal_screen.dart';
import '../../features/prescription/presentation/pages/medication_reminder_screen.dart';
import '../../features/telemedicine/presentation/pages/telemedicine_screen.dart';
import '../../features/gamification/presentation/pages/gamification_screen.dart';
import '../../features/home/home_placeholder.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.symptom:
        return MaterialPageRoute(builder: (_) => const SymptomScreen());
      case AppRoutes.adviceResult:
        return MaterialPageRoute(builder: (_) => const AdviceResultScreen());
      case AppRoutes.emergencyAlert:
        return MaterialPageRoute(builder: (_) => const EmergencyAlertScreen());
      case AppRoutes.prescriptionUpload:
        return MaterialPageRoute(builder: (_) => const PrescriptionUploadScreen());
      case AppRoutes.medicineDetail:
        return MaterialPageRoute(
          builder: (_) => const MedicineDetailScreen(),
          settings: settings,
        );
      case AppRoutes.waterTracker:
        return MaterialPageRoute(builder: (_) => const WaterTrackerScreen());
      case AppRoutes.bmi:
        return MaterialPageRoute(builder: (_) => const BMIScreen());
      case AppRoutes.bloodPressure:
        return MaterialPageRoute(builder: (_) => const BloodPressureScreen());
      case AppRoutes.aiChat:
        return MaterialPageRoute(builder: (_) => const AIChatScreen());
        
      case AppRoutes.labReport:
        return MaterialPageRoute(builder: (_) => const LabReportScreen());

      case AppRoutes.dietPlanner:
        return MaterialPageRoute(builder: (_) => const DietPlannerScreen());
      case AppRoutes.dietResult:
        return MaterialPageRoute(builder: (_) => const DietResultScreen());

      case AppRoutes.pillIdentification:
        return MaterialPageRoute(builder: (_) => const PillIdentificationScreen());

      case AppRoutes.mentalHealth:
        return MaterialPageRoute(builder: (_) => const MoodJournalScreen());

      case AppRoutes.medicationReminder:
        return MaterialPageRoute(builder: (_) => const MedicationReminderScreen());

      case AppRoutes.telemedicine:
        return MaterialPageRoute(builder: (_) => const TelemedicineScreen());

      case AppRoutes.wearable:
        return MaterialPageRoute(builder: (_) => const WearableScreen());

      case AppRoutes.gamification:
        return MaterialPageRoute(builder: (_) => const GamificationScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
