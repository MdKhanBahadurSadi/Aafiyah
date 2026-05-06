import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aafiyah/core/state/app_state.dart';
import 'package:aafiyah/core/widgets/app_button.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/navigation/app_routes.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';
import 'package:aafiyah/features/pill_identification/pill_state.dart';

class PillIdentificationScreen extends StatelessWidget {
  const PillIdentificationScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pillState = context.read<PillState>();
    
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        pillState.setPillImage(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pillState = context.watch<PillState>();
    final identifiedPill = pillState.identifiedPill;
    final pillImage = pillState.pillImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pill Identifier'),
        actions: [
          if (pillImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => pillState.reset(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const Text('Identify Your Medicine', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Upload a clear photo of the pill or medicine packaging to get detailed information.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Upload Area / Preview
            GestureDetector(
              onTap: appState.isLoading ? null : () => _showPickerOptions(context),
              child: _buildUploadPreview(appState.isLoading, pillImage),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            AppButton(
              text: appState.isLoading ? 'Identifying...' : 'Identify Medicine',
              isLoading: appState.isLoading,
              onPressed: pillImage == null || appState.isLoading
                  ? null
                  : () => pillState.identify(appState),
            ),
            
            if (appState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Center(
                  child: Text(
                    appState.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
            const SizedBox(height: AppSpacing.xl),
            
            if (identifiedPill != null) ...[
              const Text('Identification Result', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.medicineDetail,
                  arguments: identifiedPill,
                ),
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.medication_rounded, color: Colors.teal, size: 32),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(identifiedPill.name, style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
                                const SizedBox(height: 4),
                                const Text('Verified by Aafiyah AI', style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                      Divider(height: 32, color: AppColors.glassBorder),
                      _buildInfoRow(Icons.help_outline_rounded, 'Common Usage', identifiedPill.usage),
                      const SizedBox(height: AppSpacing.md),
                      _buildInfoRow(Icons.warning_amber_rounded, 'Safety Warning', identifiedPill.warning),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelLarge.copyWith(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPreview(bool isIdentifying, File? pillImage) {
    return Center(
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder, width: 2),
            image: pillImage != null 
                ? DecorationImage(
                    image: FileImage(pillImage), 
                    fit: BoxFit.cover, 
                    opacity: 0.6,
                  ) 
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (pillImage == null && !isIdentifying)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.teal.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    const Text('Tap to capture pill photo', style: AppTextStyles.bodyMedium),
                  ],
                ),
              if (pillImage != null && !isIdentifying)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Change Photo', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              if (isIdentifying) ...[
                const Icon(Icons.biotech_rounded, size: 64, color: AppColors.textSecondary),
                const _ScannerAnimation(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerAnimation extends StatefulWidget {
  const _ScannerAnimation();

  @override
  State<_ScannerAnimation> createState() => _ScannerAnimationState();
}

class _ScannerAnimationState extends State<_ScannerAnimation> with SingleTickerProviderStateMixin {
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
        return Positioned(
          top: 250 * _controller.value,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Colors.teal.withOpacity(0),
                  Colors.teal,
                  Colors.teal.withOpacity(0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
