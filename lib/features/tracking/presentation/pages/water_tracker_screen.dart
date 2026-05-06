import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/features/tracking/tracking_state.dart';
import 'package:aafiyah/features/gamification/gamification_state.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamificationState = context.read<GamificationState>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Water Hydration')),
      body: Consumer<TrackingState>(
        builder: (context, state, child) {
          final double progress = (state.todayWaterTotal / state.waterGoalMl).clamp(0.0, 1.0);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              color: AppColors.primary,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            children: [
                              const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 32),
                              const SizedBox(height: 4),
                              Text(
                                '${state.todayWaterTotal}',
                                style: AppTextStyles.headlineLarge.copyWith(fontSize: 32),
                              ),
                              Text('ml / ${state.waterGoalMl}', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickAdd(state, 250, 'Standard', gamificationState),
                          _buildQuickAdd(state, 500, 'Large', gamificationState),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Hydration History', style: AppTextStyles.headlineMedium),
                ),
                const SizedBox(height: AppSpacing.md),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.waterLogs.length,
                  itemBuilder: (context, index) {
                    final log = state.waterLogs[state.waterLogs.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            const Icon(Icons.local_drink_outlined, color: Colors.blue),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text('${log.amountMl} ml Intake', style: AppTextStyles.labelLarge),
                            ),
                            Text(
                              '${log.date.hour}:${log.date.minute.toString().padLeft(2, '0')}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAdd(TrackingState state, int amount, String label, GamificationState gamification) {
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: () => state.addWater(amount, gamification: gamification),
          icon: const Icon(Icons.add_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            foregroundColor: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text('$amount ml', style: AppTextStyles.labelLarge),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
