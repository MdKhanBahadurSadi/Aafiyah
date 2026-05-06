import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/features/symptom/symptom_state.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/disclaimer_banner.dart';

class AdviceResultScreen extends StatelessWidget {
  const AdviceResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final response = context.watch<SymptomState>().response;

    if (response == null) {
      return const Scaffold(body: Center(child: Text('No advice available.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Health Advice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Severity Level', style: AppTextStyles.headlineMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(response.severity),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Text(
                    response.severity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (response.seeDoctor)
              const Row(
                children: [
                   Icon(Icons.local_hospital, color: AppColors.primary, size: 20),
                   SizedBox(width: AppSpacing.sm),
                   Text(
                    'Consider consulting a doctor soon.',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Advice:', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(response.advice, style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppSpacing.xxl),
            const DisclaimerBanner(),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'high':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
