import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../lab_report_state.dart';

class LabReportScreen extends StatelessWidget {
  const LabReportScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      if (context.mounted) {
        context.read<LabReportState>().setImage(File(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LabReportState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Report Insight'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (state.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: state.clear,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.selectedImage == null) ...[
              const SizedBox(height: AppSpacing.xl),
              const Icon(
                Icons.analytics_outlined,
                size: 100,
                color: Colors.purpleAccent,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Upload your lab report for AI analysis',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Our AI will help you understand your blood tests, reports, and more in simple Bengali.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildUploadOptions(context),
            ] else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  state.selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.purpleAccent),
                    SizedBox(height: AppSpacing.md),
                    Text('Analyzing your report...', style: AppTextStyles.bodyLarge),
                  ],
                )
              else if (state.analysisResult != null)
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'AI Analysis',
                            style: AppTextStyles.headlineSmall.copyWith(color: Colors.purpleAccent),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: AppSpacing.xl),
                      Text(
                        state.analysisResult!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: state.analyzeReport,
                  icon: const Icon(Icons.search),
                  label: const Text('Start Analysis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOptions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _UploadButton(
            icon: Icons.camera_alt_outlined,
            label: 'Camera',
            onTap: () => _pickImage(context, ImageSource.camera),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _UploadButton(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            onTap: () => _pickImage(context, ImageSource.gallery),
          ),
        ),
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 32),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.labelLarge),
          ],
        ),
      ),
    );
  }
}
