import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:aafiyah/core/theme/app_colors.dart';
import 'package:aafiyah/core/theme/app_text_styles.dart';
import 'package:aafiyah/core/widgets/glass_card.dart';
import 'package:aafiyah/core/constants/app_spacing.dart';
import 'package:aafiyah/features/mental_health/mental_health_state.dart';
import 'package:aafiyah/features/mental_health/models/mood_log.dart';
import 'package:aafiyah/features/gamification/gamification_state.dart';

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({super.key});

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> {
  String? _selectedMood;
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Happy', 'color': Colors.amber},
    {'emoji': '😐', 'label': 'Neutral', 'color': Colors.blueGrey},
    {'emoji': '😔', 'label': 'Sad', 'color': Colors.blue},
    {'emoji': '😰', 'label': 'Anxious', 'color': Colors.deepPurple},
    {'emoji': '😠', 'label': 'Angry', 'color': Colors.redAccent},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveMood() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    final gamificationState = context.read<GamificationState>();
    context.read<MentalHealthState>().addMood(
      _selectedMood!,
      _noteController.text.isEmpty ? null : _noteController.text,
      gamification: gamificationState,
    );

    _noteController.clear();
    setState(() {
      _selectedMood = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mood logged successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MentalHealthState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Journal', style: AppTextStyles.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isGeneratingSupport)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: GlassCard(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                      ),
                      SizedBox(width: 12),
                      Text('Aafi is thinking...', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              )
            else if (state.aiSupportMessage != null) 
              _buildAIAdviceCard(state),
            
            const Text('How are you feeling today?', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moods.map((mood) => _buildMoodItem(mood)).toList(),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            const Text('Add a note (optional)', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Log Mood', style: AppTextStyles.labelLarge),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            const Text('Mood History', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            
            if (state.moodLogs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Text('No entries yet. Start tracking your mood!', style: AppTextStyles.bodyMedium),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.moodLogs.length,
                reverse: true,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final log = state.moodLogs[state.moodLogs.length - 1 - index];
                  return _buildMoodLogCard(log);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAdviceCard(MentalHealthState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: GlassCard(
        color: AppColors.secondary.withOpacity(0.1),
        borderColor: AppColors.secondary.withOpacity(0.3),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_rounded, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text('Aafi\'s Support', style: AppTextStyles.labelLarge.copyWith(color: AppColors.secondary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: () => state.clearSupportMessage(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.aiSupportMessage!,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodItem(Map<String, dynamic> mood) {
    bool isSelected = _selectedMood == mood['label'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = mood['label']),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? (mood['color'] as Color).withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? (mood['color'] as Color) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(mood['emoji'], style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 4),
          Text(
            mood['label'],
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodLogCard(MoodLog log) {
    final moodInfo = _moods.firstWhere((m) => m['label'] == log.mood, orElse: () => _moods[1]);
    
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Text(moodInfo['emoji'], style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(log.mood, style: AppTextStyles.labelLarge),
                    Text(
                      DateFormat('MMM d, h:mm a').format(log.date),
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (log.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.note!,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
