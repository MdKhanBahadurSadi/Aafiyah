import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/features/symptom/symptom_state.dart';
import 'package:aafiyah/features/symptom/models/symptom_request.dart';
import 'package:aafiyah/features/auth/auth_state.dart';
import 'package:aafiyah/core/state/app_state.dart';
import 'package:aafiyah/core/widgets/app_button.dart';
import 'package:aafiyah/core/widgets/app_text_field.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/navigation/app_routes.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final _descriptionController = TextEditingController();
  String _selectedDuration = '1-2 days';
  final List<String> _durations = ['Less than a day', '1-2 days', '3-5 days', 'More than a week'];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your symptoms')),
      );
      return;
    }

    final appState = context.read<AppState>();
    final symptomState = context.read<SymptomState>();
    final authState = context.read<AuthState>();
    
    final request = SymptomRequest(
      age: authState.user?.age ?? 25,
      gender: authState.user?.gender ?? 'Other',
      symptom: _descriptionController.text,
      duration: _selectedDuration,
    );

    await symptomState.submitSymptom(request, appState);

    if (mounted && appState.errorMessage == null) {
      final response = symptomState.response;
      if (response != null) {
        if (response.emergency) {
          Navigator.pushNamed(context, AppRoutes.emergencyAlert);
        } else {
          Navigator.pushNamed(context, AppRoutes.adviceResult);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Describe your symptoms',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _descriptionController,
              hintText: 'e.g. I have a persistent headache and slight fever...',
              maxLines: 5,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'How long have you had this?',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _selectedDuration,
              items: _durations
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedDuration = val!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
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
              text: 'Analyze Symptom',
              isLoading: appState.isLoading,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
