import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aafiyah/features/prescription/prescription_state.dart';
import 'package:aafiyah/core/state/app_state.dart';
import 'package:aafiyah/core/widgets/app_button.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/core/navigation/app_routes.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';

class PrescriptionUploadScreen extends StatelessWidget {
  const PrescriptionUploadScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final prescriptionState = context.read<PrescriptionState>();
    
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        prescriptionState.setImage(File(pickedFile.path));
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
    final prescriptionState = context.watch<PrescriptionState>();
    final medicines = prescriptionState.medicines;
    final selectedImage = prescriptionState.selectedImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Analysis'),
        actions: [
          if (selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => prescriptionState.clearImage(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const Text('Analyze Your Prescription', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Upload an image to extract medicine details and safety guidance.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Upload Area / Preview
            GestureDetector(
              onTap: appState.isLoading ? null : () => _showPickerOptions(context),
              child: _buildUploadPreview(appState.isLoading, selectedImage),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            AppButton(
              text: appState.isLoading ? 'Scanning...' : 'Analyze Prescription',
              isLoading: appState.isLoading,
              onPressed: selectedImage == null || appState.isLoading
                  ? null
                  : () => prescriptionState.analyze(appState),
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
            
            if (medicines.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Extracted Results', style: AppTextStyles.labelLarge),
                  TextButton(
                    onPressed: () async {
                      await prescriptionState.startRemindersForMedicines();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminders set for all identified medicines!')),
                        );
                        Navigator.pushNamed(context, AppRoutes.medicationReminder);
                      }
                    },
                    child: const Text('Add All to Reminders'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.medicineDetail,
                        arguments: medicine,
                      ),
                      child: GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.medication_rounded, color: AppColors.secondary),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(medicine.name, style: AppTextStyles.labelLarge),
                                  const Text('Safe Dosage Extracted', style: AppTextStyles.bodyMedium),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPreview(bool isScanning, File? selectedImage) {
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
            image: selectedImage != null 
                ? DecorationImage(
                    image: FileImage(selectedImage), 
                    fit: BoxFit.cover, 
                    opacity: 0.6,
                  ) 
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (selectedImage == null && !isScanning)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primary.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    const Text('Tap to select image', style: AppTextStyles.bodyMedium),
                  ],
                ),
              if (selectedImage != null && !isScanning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Change Image', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              if (isScanning) ...[
                const Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textSecondary),
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
                  color: AppColors.primary.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0),
                  AppColors.primary,
                  AppColors.primary.withOpacity(0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
