import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/features/gamification/gamification_state.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamificationState = context.watch<GamificationState>();
    final progress = gamificationState.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Streaks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withOpacity(0.15),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPointsCard(progress.totalPoints),
                  const SizedBox(height: AppSpacing.xl),
                  
                  const Text('Active Streaks', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildStreakGrid(progress),
                  const SizedBox(height: AppSpacing.xl),
                  
                  const Text('Your Badges', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildBadgesList(progress.earnedBadges),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(int points) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Points', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('$points XP', style: AppTextStyles.headlineLarge.copyWith(color: Colors.amber)),
            ],
          ),
          const Icon(Icons.stars_rounded, color: Colors.amber, size: 64),
        ],
      ),
    );
  }

  Widget _buildStreakGrid(dynamic progress) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.1,
      children: [
        _buildStreakCard('Daily Login', progress.loginStreak, Icons.login_rounded, Colors.blue),
        _buildStreakCard('Medicine', progress.medicineStreak, Icons.medication_rounded, Colors.green),
        _buildStreakCard('Steps Goal', progress.stepStreak, Icons.directions_walk_rounded, Colors.orange),
        _buildStreakCard('Water Goal', progress.waterStreak, Icons.local_drink_rounded, Colors.cyan),
      ],
    );
  }

  Widget _buildStreakCard(String title, int days, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.labelLarge),
          const SizedBox(height: 4),
          Text(
            '$days Day${days == 1 ? '' : 's'}',
            style: AppTextStyles.headlineMedium.copyWith(color: color, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesList(List<String> badges) {
    if (badges.isEmpty) {
      return const GlassCard(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text('Keep going to earn your first badge!', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: badges.map((badgeId) => _buildBadgeItem(badgeId)).toList(),
    );
  }

  Widget _buildBadgeItem(String badgeId) {
    // Map badgeId to UI
    String title = badgeId.replaceAll('_', ' ').toUpperCase();
    IconData icon = Icons.workspace_premium_rounded;
    Color color = Colors.amber;

    if (badgeId.contains('medicine')) {
      icon = Icons.health_and_safety_rounded;
      color = Colors.green;
    } else if (badgeId.contains('step')) {
      icon = Icons.bolt_rounded;
      color = Colors.orange;
    } else if (badgeId.contains('water')) {
      icon = Icons.waves_rounded;
      color = Colors.cyan;
    }

    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
