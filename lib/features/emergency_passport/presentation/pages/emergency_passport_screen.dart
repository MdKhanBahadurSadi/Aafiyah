import 'package:flutter/material.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';
import '../../models/health_passport.dart';

class EmergencyPassportScreen extends StatelessWidget {
  const EmergencyPassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final passport = HealthPassport(
      fullName: "Md. Rahim Ahmed",
      bloodGroup: "O+",
      allergies: ["Penicillin", "Peanuts"],
      chronicConditions: ["Hypertension", "Asthma"],
      emergencyContactName: "Fatema Begum (Wife)",
      emergencyContactPhone: "+8801712345678",
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Health Passport"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Show this QR Code to emergency medical responders or doctors for instant access to critical health info.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2, size: 120, color: Colors.black87),
                            Text("Aafiyah Secure QR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(passport.fullName, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Chip(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      label: Text("Blood Group: ${passport.bloodGroup}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Medical Alerts", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    const Divider(),
                    Text("Allergies: ${passport.allergies.join(', ')}"),
                    const SizedBox(height: 8),
                    Text("Chronic Conditions: ${passport.chronicConditions.join(', ')}"),
                    const SizedBox(height: 16),
                    const Text("Emergency Contact", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Divider(),
                    Text("Name: ${passport.emergencyContactName}"),
                    Text("Phone: ${passport.emergencyContactPhone}"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
