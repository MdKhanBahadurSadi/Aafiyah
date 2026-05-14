import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/state/app_state.dart';
import '../../../auth/auth_state.dart';
import '../widgets/doctor_card.dart';
import 'appointment_booking_screen.dart';
import '../../telemedicine_state.dart';
import '../../models/doctor_model.dart';
import '../../models/appointment_model.dart';

class TelemedicineScreen extends StatefulWidget {
  const TelemedicineScreen({super.key});

  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _symptomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      final authState = Provider.of<AuthState>(context, listen: false);
      final teleState = Provider.of<TelemedicineState>(context, listen: false);
      
      teleState.fetchDoctors(appState);
      if (authState.user != null) {
        teleState.fetchAppointments(authState.user!.uid, appState);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Telemedicine', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Find Doctors'),
            Tab(text: 'My Appointments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDoctorsList(),
          _buildAppointmentsList(),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return Consumer2<TelemedicineState, AppState>(
      builder: (context, telemedicineState, appState, child) {
        final doctors = telemedicineState.doctors;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart AI Suggestion Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.2), AppColors.secondary.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'AI Doctor Suggestion',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _symptomController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'আপনার সমস্যা লিখুন (যেমন: আমার জ্বর হয়েছে)...',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
                        suffixIcon: IconButton(
                          icon: appState.isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : const Icon(Icons.send, color: AppColors.primary),
                          onPressed: () {
                            if (_symptomController.text.isNotEmpty) {
                              telemedicineState.getSmartSuggestions(_symptomController.text, appState);
                            }
                          },
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          telemedicineState.getSmartSuggestions(value, appState);
                        }
                      },
                    ),
                    if (telemedicineState.aiSuggestion.isNotEmpty) ...[
                      const Divider(color: AppColors.glassBorder),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: MarkdownBody(
                            data: telemedicineState.aiSuggestion,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Available Specialists',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: doctors.isEmpty 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return DoctorCard(
                        doctor: doctor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentBookingScreen(doctor: doctor),
                            ),
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentsList() {
    return Consumer<TelemedicineState>(
      builder: (context, state, child) {
        if (state.appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text(
                  'No appointments yet',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Book Now', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.appointments.length,
          itemBuilder: (context, index) {
            final appt = state.appointments[index];
            final doctor = state.doctors.firstWhere(
              (d) => d.id == appt.doctorId, 
              orElse: () => const DoctorModel(id: '', name: 'Doctor', specialty: '', imageUrl: '', rating: 0, reviews: 0, bio: '', consultationFee: 0)
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.videocam, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name.isNotEmpty ? doctor.name : 'Consultation',
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy - hh:mm a').format(appt.dateTime),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appt.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            appt.status.name.toUpperCase(),
                            style: TextStyle(color: _getStatusColor(appt.status), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed: return AppColors.success;
      case AppointmentStatus.pending: return AppColors.warning;
      case AppointmentStatus.cancelled: return AppColors.error;
      case AppointmentStatus.completed: return AppColors.primary;
    }
  }
}
