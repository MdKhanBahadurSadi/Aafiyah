import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/features/auth/auth_state.dart';
import 'package:aafiyah/core/navigation/app_routes.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/widgets/ai_companion_overlay.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final user = authState.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  _buildHeader(context, user?.name ?? 'User'),
                  const SizedBox(height: AppSpacing.xl),
                  
                  _buildPulseSection(),
                  const SizedBox(height: AppSpacing.xl),
                  
                  const Text('AI Health Intelligence', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildAIFeatureCard(
                    context,
                    title: 'Symptom Genius',
                    subtitle: 'AI-driven health analysis and guidance',
                    icon: Icons.psychology_outlined,
                    color: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.symptom),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildAIFeatureCard(
                    context,
                    title: 'Prescription Vision',
                    subtitle: 'Extract insights from your prescriptions',
                    icon: Icons.receipt_long_outlined,
                    color: AppColors.secondary,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.prescriptionUpload),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildAIFeatureCard(
                    context,
                    title: 'Lab Report Insight',
                    subtitle: 'AI analysis of your medical reports',
                    icon: Icons.analytics_outlined,
                    color: Colors.purpleAccent,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.labReport),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  const Text('Daily Wellness', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.5,
                    children: [
                      _buildFeatureSquare(context, 'Diet Planner', Icons.restaurant_menu_rounded, Colors.orange, AppRoutes.dietPlanner),
                      _buildFeatureSquare(context, 'Pill ID', Icons.medication_rounded, Colors.teal, AppRoutes.pillIdentification),
                      _buildFeatureSquare(context, 'Mood Journal', Icons.mood_rounded, Colors.pinkAccent, AppRoutes.mentalHealth),
                      _buildFeatureSquare(context, 'Reminders', Icons.alarm_on_rounded, Colors.indigoAccent, AppRoutes.medicationReminder),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  const Text('Health Tracking', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    children: [
                      _buildTrackerCard(context, 'Water', Icons.local_drink_outlined, Colors.blue, AppRoutes.waterTracker),
                      _buildTrackerCard(context, 'Heart', Icons.favorite_border_rounded, Colors.redAccent, AppRoutes.bloodPressure),
                      _buildTrackerCard(context, 'BMI', Icons.monitor_weight_outlined, AppColors.success, AppRoutes.bmi),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  const Text('Connectivity & Safety', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildAIFeatureCard(
                    context,
                    title: 'Telemedicine',
                    subtitle: 'Consult with doctors online',
                    icon: Icons.video_call_outlined,
                    color: Colors.cyan,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.telemedicine),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallCard(context, 'SOS Alert', Icons.emergency_share_rounded, Colors.red, AppRoutes.emergencyAlert),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildSmallCard(context, 'Wearables', Icons.watch_rounded, Colors.blueGrey, AppRoutes.wearable),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                   _buildAIFeatureCard(
                    context,
                    title: 'Gamification & Streaks',
                    subtitle: 'Earn rewards for staying healthy',
                    icon: Icons.emoji_events_outlined,
                    color: Colors.amber,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.gamification),
                  ),

                  const SizedBox(height: 120), // Space for floating assistant
                ],
              ),
            ),
          ),
          
          AICompanionOverlay(
            onTap: () => Navigator.pushNamed(context, AppRoutes.aiChat),
          ),
          
          // Custom Top Bar (Logout)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
              onPressed: () async {
                await authState.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name',
          style: AppTextStyles.headlineLarge.copyWith(height: 1.1),
        ),
        const SizedBox(height: 4),
        Text(
          "Your health companion is ready.",
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPulseSection() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.xl),
      child: Row(
        children: [
          _PulseIndicator(),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Wellness', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  'Optimized',
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildAIFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSquare(BuildContext context, String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.labelLarge, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.labelLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.labelLarge.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(1 - _controller.value),
                  width: 4 * _controller.value,
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.background, size: 20),
            ),
          ],
        );
      },
    );
  }
}
