import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/auth_state.dart';
import '../../diet_state.dart';
import '../../../../core/navigation/app_routes.dart';

class DietPlannerScreen extends StatefulWidget {
  const DietPlannerScreen({super.key});

  @override
  State<DietPlannerScreen> createState() => _DietPlannerScreenState();
}

class _DietPlannerScreenState extends State<DietPlannerScreen> {
  final _symptomsController = TextEditingController();
  final _healthStatusController = TextEditingController();
  final _preferencesController = TextEditingController();
  final _restrictionsController = TextEditingController();

  @override
  void dispose() {
    _symptomsController.dispose();
    _healthStatusController.dispose();
    _preferencesController.dispose();
    _restrictionsController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final appState = context.read<AppState>();
    final dietState = context.read<DietState>();
    final authState = context.read<AuthState>();

    await dietState.generatePlan(
      age: authState.user?.age ?? 30,
      gender: authState.user?.gender ?? 'Other',
      symptoms: _symptomsController.text.trim(),
      healthStatus: _healthStatusController.text.trim(),
      preferences: _preferencesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      restrictions: _restrictionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      appState: appState,
    );

    if (mounted && appState.errorMessage == null) {
      Navigator.pushNamed(context, AppRoutes.dietResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('AI Diet Planner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalize Your Diet Plan',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Tell us about your health and preferences to generate a tailored plan.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            _buildLabel('Symptoms (if any)'),
            AppTextField(
              controller: _symptomsController,
              hintText: 'e.g. Fatigue, indigestion',
            ),
            const SizedBox(height: AppSpacing.md),

            _buildLabel('Current Health Status'),
            AppTextField(
              controller: _healthStatusController,
              hintText: 'e.g. Diabetes, Hypertension, Healthy',
            ),
            const SizedBox(height: AppSpacing.md),

            _buildLabel('Dietary Preferences (comma separated)'),
            AppTextField(
              controller: _preferencesController,
              hintText: 'e.g. Vegetarian, High protein',
            ),
            const SizedBox(height: AppSpacing.md),

            _buildLabel('Dietary Restrictions (comma separated)'),
            AppTextField(
              controller: _restrictionsController,
              hintText: 'e.g. Peanut allergy, Lactose intolerant',
            ),
            const SizedBox(height: AppSpacing.xl),

            if (appState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  appState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            AppButton(
              text: 'Generate Diet Plan',
              isLoading: appState.isLoading,
              onPressed: _handleGenerate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTextStyles.labelLarge,
      ),
    );
  }
}
