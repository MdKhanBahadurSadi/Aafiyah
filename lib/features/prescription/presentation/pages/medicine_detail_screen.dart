import 'package:flutter/material.dart';
import 'package:aafiyah/features/prescription/models/medicine_model.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';

class MedicineDetailScreen extends StatelessWidget {
  const MedicineDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicine = ModalRoute.of(context)!.settings.arguments as MedicineModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.medication_liquid_rounded, size: 64, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(medicine.name, style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 4),
                  const Text('AI Verified Prescription Item', style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            _buildGlassSection('Usage Instructions', medicine.usage, Icons.info_outline, AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            
            _buildGlassSection('Possible Side Effects', medicine.sideEffects, Icons.warning_amber_rounded, AppColors.secondary),
            const SizedBox(height: AppSpacing.lg),
            
            _buildGlassSection('Critical Warning', medicine.warning, Icons.report_problem_outlined, AppColors.error),
            
            const SizedBox(height: AppSpacing.xxl),
            const GlassCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.gpp_good_outlined, color: AppColors.success),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'AI analysis is for informational purposes. Always consult your doctor.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSection(String title, String content, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
