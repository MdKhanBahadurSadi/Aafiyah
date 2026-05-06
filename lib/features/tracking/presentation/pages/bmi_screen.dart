import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/features/tracking/tracking_state.dart';
import 'package:aafiyah/features/tracking/models/bmi_result.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/widgets/app_button.dart';
import 'package:aafiyah/core/widgets/app_text_field.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  BMIResult? _result;

  void _calculate() {
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    if (height > 0 && weight > 0) {
      setState(() {
        _result = context.read<TrackingState>().calculateBMI(height, weight);
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
        child: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  AppTextField(
                    hintText: 'Height (cm)',
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    hintText: 'Weight (kg)',
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    text: 'Calculate Now',
                    onPressed: _calculate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (_result != null)
              _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final categoryColor = _getCategoryColor(_result!.category);
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      borderColor: categoryColor.withOpacity(0.3),
      child: Column(
        children: [
          const Text('Your Health Index', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _result!.value.toStringAsFixed(1),
            style: AppTextStyles.headlineLarge.copyWith(fontSize: 56, color: categoryColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: categoryColor.withOpacity(0.2)),
            ),
            child: Text(
              _result!.category.toUpperCase(),
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: categoryColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Keep a balanced diet and regular exercise for optimal wellness.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Underweight': return Colors.orangeAccent;
      case 'Normal': return AppColors.success;
      case 'Overweight': return Colors.orange;
      case 'Obese': return Colors.redAccent;
      default: return AppColors.textPrimary;
    }
  }
}
