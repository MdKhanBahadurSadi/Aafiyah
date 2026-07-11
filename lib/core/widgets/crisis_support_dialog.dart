import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_spacing.dart';

class CrisisSupportDialog extends StatelessWidget {
  const CrisisSupportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.support_agent, color: Colors.red, size: 28),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'We Care About You',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'It sounds like you are going through a difficult time. You are not alone, and help is available right now.',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Please reach out to trusted professionals or emergency services immediately:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: Icon(Icons.phone_in_talk, color: Colors.green),
              title: Text('National Emergency Service (999)'),
              subtitle: Text('Available 24/7 for immediate emergency help'),
              dense: true,
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.redAccent),
              title: Text('Mental Health Helpline (Kaan Pete Roi)'),
              subtitle: Text('Confidential emotional support'),
              dense: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            // Action to call emergency or helpline
            Navigator.of(context).pop();
          },
          child: const Text('Call 999', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
