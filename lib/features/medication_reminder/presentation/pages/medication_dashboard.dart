import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/medication_state.dart';
import 'add_medication_page.dart';
import '../widgets/medication_card.dart';
import '../widgets/adherence_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MedicationDashboard extends StatefulWidget {
  const MedicationDashboard({super.key});

  @override
  State<MedicationDashboard> createState() => _MedicationDashboardState();
}

class _MedicationDashboardState extends State<MedicationDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<MedicationState>().loadMedications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medication Center', style: AppTextStyles.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.textPrimary),
            onPressed: () {
              // Navigate to history
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Consumer<MedicationState>(
            builder: (context, state, child) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AdherenceSummary(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Routine',
                          style: AppTextStyles.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All', style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state.medications.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(Icons.medication_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              const Text('Your medicine cabinet is empty', style: AppTextStyles.bodyLarge),
                              const Text('Add your first medication to get started', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.medications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final medication = state.medications[index];
                          return MedicationCard(medication: medication);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicationPage()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        label: const Text('Add Medicine', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
