import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/pharmacy_repository.dart';
import '../../domain/pharmacy_models.dart';
import 'medicine_pharmacy_home_page.dart';

class RefillsTab extends StatefulWidget {
  const RefillsTab({
    super.key,
    required this.repository,
    required this.pharmacies,
    required this.latitude,
    required this.longitude,
  });
  final PharmacyRepository repository;
  final List<Pharmacy> pharmacies;
  final double latitude;
  final double longitude;
  @override
  State<RefillsTab> createState() => _RefillsTabState();
}

class _RefillsTabState extends State<RefillsTab> {
  late Future<List<Map<String, dynamic>>> _plans;
  String? _activeRequest;
  bool _busy = false;
  final NotificationService _notifications = NotificationService();
  @override
  void initState() {
    super.initState();
    _plans = widget.repository.listMedicationPlans();
  }

  void _reload() =>
      setState(() => _plans = widget.repository.listMedicationPlans());

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.md),
    children: [
      const Text(
        'Medication supply & refills',
        style: AppTextStyles.headlineMedium,
      ),
      const Text(
        'Reminders estimate when your recorded supply may run out. They do not extend a treatment plan or place orders. Check your current prescription and confirm any order yourself.',
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: () async {
          if (widget.pharmacies.isEmpty) {
            _message(
              'Find nearby pharmacies first, then choose a preferred pharmacy.',
            );
            return;
          }
          final result = await showModalBottomSheet<_PlanInput>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => MedicationPlanEditor(pharmacies: widget.pharmacies),
          );
          if (result == null) return;
          setState(() => _busy = true);
          try {
            final id = await widget.repository.createMedicationPlan(
              name: result.name,
              strength: result.strength,
              remainingQuantity: result.quantity,
              unitsPerDay: result.unitsPerDay,
              preferredPharmacyId: result.pharmacy.id,
              prescriptionRequired: result.prescriptionRequired,
              prescriptionExpiresAt: result.expiry,
            );
            final estimate = RefillEstimate.fromSupply(
              remainingQuantity: result.quantity,
              unitsPerDay: result.unitsPerDay,
              asOf: DateTime.now(),
            )!;
            await _scheduleReminder(id, result.name, estimate.remindAt);
            _reload();
          } catch (error) {
            _message(error.toString());
          } finally {
            if (mounted) setState(() => _busy = false);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_busy ? 'Saving…' : 'Add medication supply'),
      ),
      const SizedBox(height: 12),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: _plans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Text(
              'Sign in to manage refill reminders. ${snapshot.error}',
            );
          if (snapshot.data!.isEmpty)
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No medication supply plans yet.'),
            );
          return Column(
            children: [for (final plan in snapshot.data!) _planCard(plan)],
          );
        },
      ),
      if (_activeRequest != null) ...[
        const SizedBox(height: 12),
        const Text('Pharmacy responses', style: AppTextStyles.headlineMedium),
        StreamBuilder<List<PharmacyQuotation>>(
          stream: widget.repository.watchQuotes(_activeRequest!),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            if (snapshot.data!.isEmpty)
              return const Text(
                'Waiting for the selected pharmacy. The request expires after 30 minutes.',
              );
            return Column(
              children: [
                QuoteComparisonTable(quotes: snapshot.data!),
                for (final quote in snapshot.data!)
                  QuoteCard(quote: quote, repository: widget.repository),
              ],
            );
          },
        ),
      ],
    ],
  );

  Widget _planCard(Map<String, dynamic> plan) {
    final expiry = _date(plan['prescriptionExpiresAt']);
    final runOut = _date(plan['estimatedRunOutAt']);
    final remindAt = _date(plan['remindAt']);
    final bool active = plan['active'] == true;
    final String name = plan['name'] as String? ?? 'Medicine';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$name ${plan['strength'] ?? ''}',
                    style: AppTextStyles.headlineMedium,
                  ),
                ),
                Icon(
                  active
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ],
            ),
            Text(
              '${plan['remainingQuantity']} units remaining · ${(plan['unitsPerDay'] as num?)?.toStringAsFixed(2) ?? '—'} units/day',
            ),
            Text(
              'Estimated supply end: ${_format(runOut)} · reminder: ${_format(remindAt)}',
            ),
            if (plan['prescriptionRequired'] == true)
              Text(
                expiry == null
                    ? 'Prescription expiry not recorded or verified'
                    : 'Patient-entered expiry: ${_format(expiry)} · pharmacist verification required',
                style: const TextStyle(color: AppColors.warning),
              ),
            Wrap(
              spacing: 8,
              children: [
                if (active)
                  TextButton.icon(
                    onPressed: () => _checkRefill(plan),
                    icon: const Icon(Icons.search),
                    label: const Text('Check availability'),
                  ),
                if (active)
                  TextButton.icon(
                    onPressed: () => _snooze(plan),
                    icon: const Icon(Icons.snooze),
                    label: const Text('Snooze 1 day'),
                  ),
                TextButton.icon(
                  onPressed: () => _showHistory(plan),
                  icon: const Icon(Icons.history),
                  label: const Text('Reminder history'),
                ),
                TextButton.icon(
                  onPressed: () => _setActive(plan, !active),
                  icon: Icon(active ? Icons.pause : Icons.play_arrow),
                  label: Text(active ? 'Pause reminders' : 'Resume'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkRefill(Map<String, dynamic> plan) async {
    final expires = _date(plan['prescriptionExpiresAt']);
    if (plan['prescriptionRequired'] == true &&
        (plan['prescriptionExpiryVerified'] != true ||
            expires == null ||
            !expires.isAfter(DateTime.now()))) {
      final pharmacy = widget.pharmacies
          .where((p) => p.id == plan['preferredPharmacyId'])
          .firstOrNull;
      if (pharmacy == null) {
        _message(
          'The preferred pharmacy is not in the current nearby results. Refresh your location first.',
        );
        return;
      }
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Updated prescription needed'),
          content: const Text(
            'This plan requires a current prescription, but its expiry has not been verified by a pharmacist or has passed. Upload updated documentation before requesting refill fulfillment.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Upload prescription'),
            ),
          ],
        ),
      );
      if (confirm == true && mounted)
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PrescriptionRequestPage(
              repository: widget.repository,
              pharmacies: [pharmacy],
              latitude: widget.latitude,
              longitude: widget.longitude,
            ),
          ),
        );
      return;
    }
    final pharmacyId = plan['preferredPharmacyId'] as String?;
    if (pharmacyId == null) {
      _message('Choose a preferred pharmacy.');
      return;
    }
    try {
      final request = await widget.repository.createAvailabilityRequest(
        medicineName: plan['name'] as String? ?? '',
        strength: plan['strength'] as String? ?? '',
        formulation: '',
        quantity: (plan['remainingQuantity'] as num?)?.ceil() ?? 1,
        pharmacyIds: [pharmacyId],
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (mounted) setState(() => _activeRequest = request);
    } catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _snooze(Map<String, dynamic> plan) async {
    final next = DateTime.now().add(const Duration(days: 1));
    try {
      await widget.repository.updateMedicationPlan(plan['id'] as String, {
        'remindAt': Timestamp.fromDate(next),
        'reminderSentAt': null,
        'snoozedAt': FieldValue.serverTimestamp(),
      });
      await widget.repository.recordReminderSnooze(plan['id'] as String);
      await _scheduleReminder(
        plan['id'] as String,
        plan['name'] as String? ?? 'Medicine',
        next,
      );
      _reload();
    } catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _setActive(Map<String, dynamic> plan, bool active) async {
    try {
      await widget.repository.updateMedicationPlan(plan['id'] as String, {
        'active': active,
      });
      if (!active)
        await _notifications.cancelNotification(
          _notificationId(plan['id'] as String),
        );
      else {
        final at = _date(plan['remindAt']);
        if (at != null)
          await _scheduleReminder(
            plan['id'] as String,
            plan['name'] as String? ?? 'Medicine',
            at,
          );
      }
      _reload();
    } catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _showHistory(Map<String, dynamic> plan) async {
    try {
      final events = await widget.repository.medicationReminderHistory(
        plan['id'] as String,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${plan['name']} reminder history'),
          content: events.isEmpty
              ? const Text('No refill reminders have been sent or snoozed yet.')
              : SizedBox(
                  width: 360,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final event in events)
                        ListTile(
                          dense: true,
                          leading: Icon(
                            event['type'] == 'snoozed'
                                ? Icons.snooze
                                : Icons.notifications_active,
                          ),
                          title: Text(
                            event['type'] == 'snoozed'
                                ? 'Snoozed for one day'
                                : 'Reminder sent',
                          ),
                          subtitle: Text(_format(_date(event['createdAt']))),
                        ),
                    ],
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _scheduleReminder(String id, String name, DateTime when) async {
    final scheduled = when.isBefore(DateTime.now())
        ? DateTime.now().add(const Duration(minutes: 1))
        : when;
    await _notifications.scheduleMedicationNotification(
      id: _notificationId(id),
      title: 'Refill reminder: $name',
      body:
          'Your recorded supply may be running low. Check your prescription and confirm any refill yourself.',
      scheduledTime: scheduled,
      payload: 'refill:$id',
    );
  }

  int _notificationId(String id) {
    var hash = 0x811c9dc5;
    for (final unit in id.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return 1000000000 + (hash % 1000000000);
  }

  DateTime? _date(Object? value) => value is Timestamp
      ? value.toDate()
      : value is DateTime
      ? value
      : null;
  String _format(DateTime? value) => value == null
      ? 'not available'
      : '${value.toLocal().year}-${value.toLocal().month.toString().padLeft(2, '0')}-${value.toLocal().day.toString().padLeft(2, '0')}';
  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _PlanInput {
  const _PlanInput(
    this.name,
    this.strength,
    this.quantity,
    this.unitsPerDay,
    this.pharmacy,
    this.prescriptionRequired,
    this.expiry,
  );
  final String name, strength;
  final double quantity, unitsPerDay;
  final Pharmacy pharmacy;
  final bool prescriptionRequired;
  final DateTime? expiry;
}

class MedicationPlanEditor extends StatefulWidget {
  const MedicationPlanEditor({super.key, required this.pharmacies});
  final List<Pharmacy> pharmacies;
  @override
  State<MedicationPlanEditor> createState() => _MedicationPlanEditorState();
}

class _MedicationPlanEditorState extends State<MedicationPlanEditor> {
  final _name = TextEditingController();
  final _strength = TextEditingController();
  final _quantity = TextEditingController();
  final _dailyUse = TextEditingController();
  String? _pharmacyId;
  bool _requiresPrescription = false;
  DateTime? _expiry;
  @override
  void dispose() {
    _name.dispose();
    _strength.dispose();
    _quantity.dispose();
    _dailyUse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Medication supply details',
            style: AppTextStyles.headlineMedium,
          ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Medicine name'),
          ),
          TextField(
            controller: _strength,
            decoration: const InputDecoration(labelText: 'Strength'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantity,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Remaining quantity',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _dailyUse,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Units per day'),
                ),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            value: _pharmacyId,
            decoration: const InputDecoration(labelText: 'Preferred pharmacy'),
            items: [
              for (final pharmacy in widget.pharmacies)
                DropdownMenuItem(
                  value: pharmacy.id,
                  child: Text(pharmacy.name),
                ),
            ],
            onChanged: (value) => setState(() => _pharmacyId = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Prescription required'),
            value: _requiresPrescription,
            onChanged: (value) => setState(() => _requiresPrescription = value),
          ),
          if (_requiresPrescription)
            TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 3650),
                  ),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  initialDate:
                      _expiry ?? DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) setState(() => _expiry = picked);
              },
              icon: const Icon(Icons.event),
              label: Text(
                _expiry == null
                    ? 'Set prescription expiry'
                    : 'Expiry ${_expiry!.year}-${_expiry!.month}-${_expiry!.day}',
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'A reminder is scheduled about two days before estimated supply end. This calculation uses only the quantity and daily use you enter.',
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final quantity = double.tryParse(_quantity.text);
                final daily = double.tryParse(_dailyUse.text);
                final pharmacy = widget.pharmacies
                    .where((p) => p.id == _pharmacyId)
                    .firstOrNull;
                if (_name.text.trim().isEmpty ||
                    quantity == null ||
                    daily == null ||
                    pharmacy == null ||
                    (_requiresPrescription && _expiry == null))
                  return;
                Navigator.pop(
                  context,
                  _PlanInput(
                    _name.text.trim(),
                    _strength.text.trim(),
                    quantity,
                    daily,
                    pharmacy,
                    _requiresPrescription,
                    _expiry,
                  ),
                );
              },
              child: const Text('Save reminder'),
            ),
          ),
        ],
      ),
    ),
  );
}
