import 'package:flutter/material.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';

class FeaturePlaceholder extends StatelessWidget {
  final String title;

  const FeaturePlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              '$title Feature Coming Soon',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Our AI is currently building this for you.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
