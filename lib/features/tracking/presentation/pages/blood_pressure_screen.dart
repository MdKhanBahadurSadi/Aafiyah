import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/features/tracking/tracking_state.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/widgets/app_button.dart';
import 'package:aafiyah/core/widgets/app_text_field.dart';

import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();

  void _save() {
    final sys = int.tryParse(_systolicController.text) ?? 0;
    final dia = int.tryParse(_diastolicController.text) ?? 0;
    if (sys > 0 && dia > 0) {
      context.read<TrackingState>().addBloodPressure(sys, dia);
      _systolicController.clear();
      _diastolicController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blood Pressure')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          hintText: 'Systolic',
                          controller: _systolicController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          hintText: 'Diastolic',
                          controller: _diastolicController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: 'Record Reading',
                    onPressed: _save,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('History Logs', style: AppTextStyles.headlineMedium),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Consumer<TrackingState>(
                builder: (context, state, child) {
                  return ListView.builder(
                    itemCount: state.bpLogs.length,
                    itemBuilder: (context, index) {
                      final log = state.bpLogs[state.bpLogs.length - 1 - index];
                      final isHigh = log.systolic > 140 || log.diastolic > 90;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          borderColor: isHigh ? AppColors.error.withOpacity(0.3) : AppColors.glassBorder,
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite_rounded, 
                                color: isHigh ? AppColors.error : AppColors.secondary,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${log.systolic}/${log.diastolic} mmHg', 
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: isHigh ? AppColors.error : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      isHigh ? 'Elevated Reading' : 'Normal Reading',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${log.date.day}/${log.date.month} ${log.date.hour}:${log.date.minute.toString().padLeft(2, '0')}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
