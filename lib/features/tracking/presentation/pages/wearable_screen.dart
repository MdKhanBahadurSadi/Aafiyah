import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/core/services/health_service.dart';
import 'package:aafiyah/features/tracking/models/health_data.dart' as model;
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/features/gamification/gamification_state.dart';

class WearableScreen extends StatefulWidget {
  const WearableScreen({super.key});

  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen> {
  final HealthService _healthService = HealthService();
  model.HealthData? _healthData;
  bool _isLoading = false;
  bool _isAuthorized = false;
  final int stepGoal = 10000;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndFetch();
  }

  Future<void> _checkPermissionsAndFetch() async {
    setState(() => _isLoading = true);
    final authorized = await _healthService.requestPermissions();
    setState(() => _isAuthorized = authorized);

    if (authorized) {
      await _fetchData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await _healthService.fetchHealthData();
    setState(() {
      _healthData = data;
      _isLoading = false;
    });

    if (data != null && data.steps >= stepGoal && mounted) {
      context.read<GamificationState>().recordStepsGoalReached();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wearable Integration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSyncStatus(),
                      const SizedBox(height: AppSpacing.xl),
                      
                      if (!_isAuthorized)
                        _buildPermissionWarning()
                      else ...[
                        const Text('Activity & Health', style: AppTextStyles.headlineMedium),
                        const SizedBox(height: AppSpacing.md),
                        
                        _buildHealthMetricCard(
                          'Steps',
                          '${_healthData?.steps ?? 0}',
                          'steps / $stepGoal',
                          Icons.directions_walk_rounded,
                          Colors.orange,
                          progress: (_healthData?.steps ?? 0) / stepGoal,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        _buildHealthMetricCard(
                          'Heart Rate',
                          '${_healthData?.heartRate.toStringAsFixed(0) ?? 0}',
                          'bpm',
                          Icons.favorite_rounded,
                          Colors.redAccent,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        _buildHealthMetricCard(
                          'Sleep',
                          '${_healthData?.sleepHours.toStringAsFixed(1) ?? 0}',
                          'hours',
                          Icons.bedtime_rounded,
                          Colors.indigoAccent,
                        ),
                        
                        const SizedBox(height: AppSpacing.xl),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _fetchData,
                            icon: const Icon(Icons.sync_rounded),
                            label: const Text('Refresh Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isAuthorized ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isAuthorized ? Icons.check_circle_rounded : Icons.warning_rounded,
              color: _isAuthorized ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAuthorized ? 'Device Connected' : 'Not Connected',
                  style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
                ),
                Text(
                  _isAuthorized 
                      ? 'Syncing with Google Fit / Apple Health' 
                      : 'Grant permissions to sync health data',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.lock_person_rounded, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Permissions Required',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Aafiyah needs access to your health data to provide personalized insights.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: _checkPermissionsAndFetch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Grant Access'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricCard(String title, String value, String unit, IconData icon, Color color, {double? progress}) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(value, style: AppTextStyles.headlineLarge.copyWith(color: color)),
                        const SizedBox(width: 4),
                        Text(unit, style: AppTextStyles.labelLarge),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
    );
  }
}
