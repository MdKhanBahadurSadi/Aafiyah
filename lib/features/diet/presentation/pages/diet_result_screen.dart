import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../diet_state.dart';
import '../../models/diet_plan.dart';

class DietResultScreen extends StatelessWidget {
  const DietResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dietState = context.watch<DietState>();
    final dietPlan = dietState.dietPlan;

    if (dietPlan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diet Plan')),
        body: const Center(child: Text('No diet plan available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(dietPlan.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dietPlan.description,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            const Text(
              'Daily Meals',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ...dietPlan.meals.map((meal) => _buildMealCard(meal)).toList(),
            
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'General Advice',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ...dietPlan.generalAdvice.map((advice) => _buildListItem(advice, Icons.check_circle_outline, AppColors.success)).toList(),
            
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Restrictions',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ...dietPlan.restrictions.map((restriction) => _buildListItem(restriction, Icons.error_outline, AppColors.error)).toList(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal.time,
                  style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    meal.calories,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              meal.suggestion,
              style: AppTextStyles.bodyMedium,
            ),
            if (meal.recipeLink.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Recipe: ${meal.recipeLink}',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondary, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
