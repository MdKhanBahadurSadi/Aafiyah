import 'package:flutter/material.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/widgets/app_button.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';

class EmergencyAlertScreen extends StatelessWidget {
  const EmergencyAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.error.withOpacity(0.8),
              AppColors.background.withOpacity(0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'CRITICAL ALERT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  opacity: 0.05,
                  borderColor: Colors.white.withOpacity(0.2),
                  child: const Column(
                    children: [
                      Text(
                        'URGENT CARE REQUIRED',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your symptoms indicate a potentially serious condition. Please do not wait to seek professional help.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AppButton(
                  text: 'Call Emergency Services',
                  onPressed: () {
                    // Mock emergency call logic
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Dismiss (At your own risk)',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
