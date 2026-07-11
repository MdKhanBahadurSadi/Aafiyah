import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/medication_model.dart';
import '../state/medication_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';

class AddMedicationPage extends StatefulWidget {
  final Medication? medication;
  const AddMedicationPage({super.key, this.medication});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _strengthController;
  late TextEditingController _notesController;
  
  String _type = 'Tablet';
  String _foodTiming = 'After Meal';
  String _frequencyType = 'daily';
  List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();

  final List<String> _types = ['Tablet', 'Capsule', 'Syrup', 'Injection', 'Cream', 'Drops'];
  final List<String> _timings = ['Before Meal', 'After Meal', 'With Meal', 'No Preference'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.name);
    _dosageController = TextEditingController(text: widget.medication?.dosage);
    _strengthController = TextEditingController(text: widget.medication?.strength);
    _notesController = TextEditingController(text: widget.medication?.notes);
    
    if (widget.medication != null) {
      _type = widget.medication!.type;
      _foodTiming = widget.medication!.foodTiming;
      _frequencyType = widget.medication!.frequencyType;
      _times = widget.medication!.reminderTimes
          .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
          .toList();
      _startDate = widget.medication!.startDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.medication == null ? 'Add New Medicine' : 'Edit Medicine', 
                  style: AppTextStyles.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.05),
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildSectionTitle('General Information'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTextField(_nameController, 'Medicine Name', Icons.medication),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_dosageController, 'Dosage', Icons.numbers)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(_type, _types, 'Type', (v) => setState(() => _type = v!)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(_strengthController, 'Strength (e.g. 500mg)', Icons.fitness_center),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Schedule & Timing'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDropdown(_foodTiming, _timings, 'Food Timing', (v) => setState(() => _foodTiming = v!)),
                      const SizedBox(height: 16),
                      ..._times.asMap().entries.map((entry) => _buildTimeTile(entry.key, entry.value)),
                      TextButton.icon(
                        onPressed: () => setState(() => _times.add(const TimeOfDay(hour: 8, minute: 0))),
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        label: const Text('Add Another Dose', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: const Text('SAVE REMINDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary));
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
    );
  }

  Widget _buildDropdown(String value, List<String> items, String label, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTimeTile(int idx, TimeOfDay time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        tileColor: Colors.white.withOpacity(0.03),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: const Icon(Icons.access_time, color: AppColors.secondary),
        title: Text(time.format(context), style: const TextStyle(color: AppColors.textPrimary)),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
          onPressed: () => setState(() => _times.removeAt(idx)),
        ),
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: time);
          if (picked != null) setState(() => _times[idx] = picked);
        },
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one dose time')));
      return;
    }

    final med = Medication()
      ..name = _nameController.text
      ..dosage = _dosageController.text
      ..strength = _strengthController.text
      ..type = _type
      ..foodTiming = _foodTiming
      ..frequencyType = _frequencyType
      ..startDate = _startDate
      ..notes = _notesController.text
      ..reminderTimes = _times.map((t) => ReminderTime(hour: t.hour, minute: t.minute)).toList();

    if (widget.medication != null) {
      med.id = widget.medication!.id;
      context.read<MedicationState>().updateMedication(med);
    } else {
      context.read<MedicationState>().addMedication(med);
    }
    
    Navigator.pop(context);
  }
}
