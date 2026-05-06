import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/features/prescription/prescription_state.dart';
import 'package:aafiyah/features/gamification/gamification_state.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/features/prescription/models/active_medication.dart';

class MedicationReminderScreen extends StatelessWidget {
  const MedicationReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prescriptionState = context.watch<PrescriptionState>();
    final activeMeds = prescriptionState.activeMedications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
              ),
            ),
          ),
          activeMeds.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: activeMeds.length,
                  itemBuilder: (context, index) {
                    return _buildMedicationCard(context, activeMeds[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.lg),
          const Text('No active medications', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Scan a prescription to start reminders.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(BuildContext context, ActiveMedication activeMed) {
    final med = activeMed.medicine;
    final prescriptionState = context.read<PrescriptionState>();
    final gamificationState = context.read<GamificationState>();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name, style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                      Text(med.dosage ?? 'No dosage info', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmation(context, activeMed),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.divider),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  med.schedule?.join(", ") ?? "Daily",
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                ),
                const Spacer(),
                const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Stock: ${activeMed.remainingStock}',
                  style: AppTextStyles.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  prescriptionState.confirmDoseTaken(activeMed.id, gamification: gamificationState);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dose confirmed for ${med.name}')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Confirm Dose Taken'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ActiveMedication activeMed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Medication'),
        content: Text('Are you sure you want to stop reminders for ${activeMed.medicine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PrescriptionState>().removeMedication(activeMed.id);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
