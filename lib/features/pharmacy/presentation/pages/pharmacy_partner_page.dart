import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/pharmacy_repository.dart';
import '../../domain/pharmacy_models.dart';
import 'medicine_pharmacy_home_page.dart';

class PharmacyPartnerPage extends StatefulWidget {
  const PharmacyPartnerPage({super.key, required this.repository});
  final PharmacyRepository repository;
  @override
  State<PharmacyPartnerPage> createState() => _PharmacyPartnerPageState();
}

class _PharmacyPartnerPageState extends State<PharmacyPartnerPage> {
  late Future<Map<String, dynamic>?> _profile;
  @override
  void initState() {
    super.initState();
    _profile = widget.repository.pharmacyForCurrentUser();
  }

  void _refresh() =>
      setState(() => _profile = widget.repository.pharmacyForCurrentUser());

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>?>(
    future: _profile,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError)
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Sign in to access pharmacy tools. ${snapshot.error}'),
          ),
        );
      final profile = snapshot.data;
      if (profile == null)
        return PharmacyRegistrationForm(
          repository: widget.repository,
          onCreated: _refresh,
        );
      if (profile['verificationStatus'] != 'verified' ||
          profile['membershipStatus'] != 'verified') {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Icon(Icons.hourglass_top, size: 56, color: AppColors.warning),
            const SizedBox(height: 12),
            const Text(
              'Pharmacy verification pending',
              style: AppTextStyles.headlineMedium,
            ),
            Text(
              '${profile['name'] ?? 'Your pharmacy'} submitted its license details. Pharmacy access and order fulfillment stay disabled until an administrator confirms the license and account.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Status is controlled by a trusted Firebase administrator. The app cannot mark a pharmacy or pharmacist as verified.',
            ),
            OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh verification status'),
            ),
          ],
        );
      }
      return _VerifiedPartnerDashboard(
        repository: widget.repository,
        profile: profile,
        onChanged: _refresh,
      );
    },
  );
}

class PharmacyRegistrationForm extends StatefulWidget {
  const PharmacyRegistrationForm({
    super.key,
    required this.repository,
    required this.onCreated,
  });
  final PharmacyRepository repository;
  final VoidCallback onCreated;
  @override
  State<PharmacyRegistrationForm> createState() =>
      _PharmacyRegistrationFormState();
}

class _PharmacyRegistrationFormState extends State<PharmacyRegistrationForm> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _license = TextEditingController();
  double _lat = 23.8103;
  double _lon = 90.4125;
  Uint8List? _licenseBytes;
  String? _licenseName;
  String? _licenseMime;
  bool _locationSelected = false;
  bool _busy = false;
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _license.dispose();
    super.dispose();
  }

  Future<void> _chooseLocation() async {
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initial: LatLng(_lat, _lon)),
      ),
    );
    if (picked != null)
      setState(() {
        _lat = picked.latitude;
        _lon = picked.longitude;
        _locationSelected = true;
      });
  }

  Future<void> _pickLicense() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    final file = result.files.single;
    final extension = file.extension?.toLowerCase();
    setState(() {
      _licenseBytes = file.bytes;
      _licenseName = file.name;
      _licenseMime = extension == 'pdf'
          ? 'application/pdf'
          : extension == 'png'
          ? 'image/png'
          : 'image/jpeg';
    });
  }

  Future<void> _submit() async {
    if (!_locationSelected) {
      _show('Choose the pharmacy location on the map.');
      return;
    }
    if (_licenseBytes == null) {
      _show('Attach a pharmacy license document.');
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.repository.registerPharmacy(
        name: _name.text,
        phone: _phone.text,
        address: _address.text,
        latitude: _lat,
        longitude: _lon,
        licenseNumber: _license.text,
        licenseBytes: _licenseBytes!,
        licenseFileName: _licenseName!,
        licenseMimeType: _licenseMime!,
      );
      widget.onCreated();
      if (mounted) _show('Application submitted for verification.');
    } catch (error) {
      _show(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.md),
    children: [
      const Text('Register a pharmacy', style: AppTextStyles.headlineMedium),
      const Text(
        'A trusted administrator must verify business and licensing details before this pharmacy can handle patient requests.',
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'Pharmacy name'),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _phone,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Business phone'),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _address,
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'Business address'),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _license,
        decoration: const InputDecoration(labelText: 'Pharmacy license number'),
      ),
      OutlinedButton.icon(
        onPressed: _pickLicense,
        icon: const Icon(Icons.upload_file),
        label: Text(_licenseName ?? 'Attach license document (PDF, JPG, PNG)'),
      ),
      OutlinedButton.icon(
        onPressed: _chooseLocation,
        icon: const Icon(Icons.location_on_outlined),
        label: Text(
          _locationSelected
              ? 'Map location · ${_lat.toStringAsFixed(4)}, ${_lon.toStringAsFixed(4)}'
              : 'Choose pharmacy location on map',
        ),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _busy ? null : _submit,
        child: Text(_busy ? 'Submitting…' : 'Submit for verification'),
      ),
    ],
  );
}

class _VerifiedPartnerDashboard extends StatefulWidget {
  const _VerifiedPartnerDashboard({
    required this.repository,
    required this.profile,
    required this.onChanged,
  });
  final PharmacyRepository repository;
  final Map<String, dynamic> profile;
  final VoidCallback onChanged;
  @override
  State<_VerifiedPartnerDashboard> createState() =>
      _VerifiedPartnerDashboardState();
}

class _VerifiedPartnerDashboardState extends State<_VerifiedPartnerDashboard> {
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> _orders = [];
  bool _delivery = false;
  bool _cod = false;
  bool _closed = false;
  bool _busy = true;
  bool _logoBusy = false;
  bool _showInventory = false;
  String? _logoUrl;
  late Map<int, PharmacyHours> _hours;
  late Set<String> _holidays;
  late Map<String, PharmacyHours> _specialHours;
  @override
  void initState() {
    super.initState();
    _delivery = widget.profile['deliveryAvailable'] == true;
    _cod = widget.profile['codAvailable'] == true;
    _closed = widget.profile['temporaryClosed'] == true;
    _logoUrl = widget.profile['logoUrl'] as String?;
    final rawHours = widget.profile['weeklyHours'] as Map? ?? const {};
    _hours = {
      for (var day = 1; day <= 7; day++)
        day: PharmacyHours.fromMap(rawHours['$day']),
    };
    _holidays = (widget.profile['holidays'] as List? ?? const [])
        .whereType<String>()
        .toSet();
    final special = widget.profile['specialHours'] as Map? ?? const {};
    _specialHours = {
      for (final entry in special.entries)
        if (entry.key is String)
          entry.key as String: PharmacyHours.fromMap(entry.value),
    };
    _load();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      final values = await Future.wait([
        widget.repository.incomingRequests(),
        widget.repository.inventory(),
        widget.repository.partnerOrders(),
      ]);
      if (mounted)
        setState(() {
          _requests = values[0];
          _inventory = values[1];
          _orders = values[2];
        });
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _saveProfile() async {
    try {
      await widget.repository.savePharmacySettings(
        deliveryAvailable: _delivery,
        codAvailable: _cod,
        temporaryClosed: _closed,
        weeklyHours: _hours,
        holidays: _holidays,
        specialHours: _specialHours,
      );
      _message('Pharmacy settings saved.');
    } catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _uploadLogo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes == null) return;
    setState(() => _logoBusy = true);
    try {
      final mime = file!.extension?.toLowerCase() == 'png'
          ? 'image/png'
          : 'image/jpeg';
      final url = await widget.repository.uploadPharmacyLogo(
        bytes: file.bytes!,
        mimeType: mime,
      );
      if (mounted) setState(() => _logoUrl = url);
      _message('Pharmacy logo updated.');
    } catch (error) {
      _message(error.toString());
    } finally {
      if (mounted) setState(() => _logoBusy = false);
    }
  }

  Future<void> _editHours(int day) async {
    final current =
        _hours[day] ??
        const PharmacyHours(open: false, from: '09:00', to: '21:00');
    final picked = await showDialog<PharmacyHours>(
      context: context,
      builder: (context) => _HoursEditor(initial: current),
    );
    if (picked != null) setState(() => _hours[day] = picked);
  }

  Future<void> _addOperatingException() async {
    final exception = await showDialog<_OperatingException>(
      context: context,
      builder: (_) => const _OperatingExceptionEditor(),
    );
    if (exception == null) return;
    setState(() {
      if (exception.holiday) {
        _holidays.add(exception.date);
        _specialHours.remove(exception.date);
      } else {
        _holidays.remove(exception.date);
        _specialHours[exception.date] = exception.hours!;
      }
    });
  }

  List<String> get _exceptionDates =>
      <String>{..._holidays, ..._specialHours.keys}.toList()..sort();

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _load,
    child: ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.profile['name'] as String? ?? 'Pharmacy dashboard',
                style: AppTextStyles.headlineMedium,
              ),
            ),
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          ],
        ),
        Text('${widget.profile['address'] ?? ''} · Verified pharmacy'),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withValues(alpha: .15),
              backgroundImage: _logoUrl == null
                  ? null
                  : NetworkImage(_logoUrl!),
              child: _logoUrl == null
                  ? const Icon(Icons.local_pharmacy, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _logoBusy ? null : _uploadLogo,
              icon: const Icon(Icons.image_outlined),
              label: Text(_logoBusy ? 'Uploading…' : 'Upload pharmacy logo'),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Home delivery'),
          value: _delivery,
          onChanged: (value) => setState(() => _delivery = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Cash on delivery'),
          value: _cod,
          onChanged: (value) => setState(() => _cod = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Temporarily closed'),
          value: _closed,
          onChanged: (value) => setState(() => _closed = value),
        ),
        OutlinedButton.icon(
          onPressed: _saveProfile,
          icon: const Icon(Icons.schedule),
          label: const Text('Configure weekly opening hours'),
        ),
        for (var day = 1; day <= 7; day++)
          _HoursSettingRow(
            day: day,
            hours: _hours[day],
            onTap: () => _editHours(day),
          ),
        OutlinedButton.icon(
          onPressed: _addOperatingException,
          icon: const Icon(Icons.event_busy),
          label: const Text('Add holiday or special hours'),
        ),
        for (final date in _exceptionDates)
          ListTile(
            dense: true,
            title: Text(date),
            subtitle: Text(
              _holidays.contains(date)
                  ? 'Holiday · closed'
                  : '${_specialHours[date]?.from}–${_specialHours[date]?.to}',
            ),
            trailing: IconButton(
              onPressed: () => setState(() {
                _holidays.remove(date);
                _specialHours.remove(date);
              }),
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        FilledButton(
          onPressed: _saveProfile,
          child: const Text('Save pharmacy settings'),
        ),
        const Divider(height: 32),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('Requests & orders'),
              icon: Icon(Icons.receipt_long),
            ),
            ButtonSegment(
              value: true,
              label: Text('Inventory'),
              icon: Icon(Icons.inventory_2),
            ),
          ],
          selected: {_showInventory},
          onSelectionChanged: (values) =>
              setState(() => _showInventory = values.first),
        ),
        if (_busy)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_showInventory)
          _buildInventory()
        else
          _buildRequestsAndOrders(),
      ],
    ),
  );

  Widget _buildInventory() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Text('Inventory', style: AppTextStyles.headlineMedium),
          ),
          IconButton(
            onPressed: () => _editInventory(),
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
          ),
        ],
      ),
      const Text(
        'Stock is displayed with a confirmation timestamp. Keep stock quantities current.',
      ),
      if (_inventory.isEmpty)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No inventory items yet.'),
        ),
      for (final item in _inventory)
        Card(
          child: ListTile(
            onTap: () => _editInventory(existing: item),
            title: Text('${item['medicineName']} ${item['strength'] ?? ''}'),
            subtitle: Text(
              'Qty ${item['quantity']} · ৳${item['unitPrice']} · confirmed ${_formatDate(item['lastStockConfirmedAt'])}',
            ),
            trailing: const Icon(Icons.edit_outlined),
          ),
        ),
    ],
  );

  Widget _buildRequestsAndOrders() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(
        'Incoming requests (${_requests.length})',
        style: AppTextStyles.headlineMedium,
      ),
      if (_requests.isEmpty)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text('No active requests.'),
        ),
      for (final request in _requests)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['type'] == 'prescription'
                      ? 'Prescription request'
                      : '${request['medicineName'] ?? 'Medicine'} · ${request['strength'] ?? ''}',
                  style: AppTextStyles.headlineMedium,
                ),
                Text(
                  '${request['status']} · expires ${_formatDate(request['expiresAt'])}',
                ),
                if (request['type'] == 'prescription')
                  Wrap(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openPrescription(request),
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('View authorized prescription'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _prepareQuote(request),
                        icon: const Icon(Icons.request_quote_outlined),
                        label: const Text('Review & quote'),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _prepareQuote(request),
                    icon: const Icon(Icons.reply),
                    label: const Text('Respond to availability request'),
                  ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 12),
      Text('Orders (${_orders.length})', style: AppTextStyles.headlineMedium),
      for (final order in _orders)
        Card(
          child: ListTile(
            title: Text(
              '${order['pharmacyName'] ?? 'Order'} · ৳${order['total']}',
            ),
            subtitle: Text('${order['status']} · ${order['paymentMethod']}'),
            trailing: _nextOrderAction(order),
          ),
        ),
    ],
  );

  Widget _nextOrderAction(Map<String, dynamic> order) {
    final String? status = order['status'] as String?;
    final next = switch (status) {
      'confirmed' => MedicineOrderStatus.processing,
      'processing' => MedicineOrderStatus.dispatched,
      'dispatched' => MedicineOrderStatus.delivered,
      _ => null,
    };
    return next == null
        ? const SizedBox.shrink()
        : TextButton(
            onPressed: () async {
              try {
                await widget.repository.updateOrderStatus(
                  order['id'] as String,
                  next,
                );
                await _load();
              } catch (e) {
                _message(e.toString());
              }
            },
            child: Text('Mark ${next.name}'),
          );
  }

  Future<void> _openPrescription(Map<String, dynamic> request) async {
    try {
      final data = await widget.repository.getPrescriptionForRequest(request);
      final bytes = await widget.repository.readPrescription(
        data['storagePath'] as String,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PrescriptionDocumentViewer(
            bytes: bytes,
            mimeType: data['mimeType'] as String? ?? 'application/octet-stream',
          ),
        ),
      );
    } catch (error) {
      _message(error.toString());
    }
  }

  Future<void> _prepareQuote(Map<String, dynamic> request) async {
    if (request['type'] == 'prescription') {
      final reviewed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Review the original prescription'),
          content: const Text(
            'Open and review the original prescription first. Only a verified pharmacist account may confirm prescription checks. The OCR text is not a substitute for this review.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue to quotation'),
            ),
          ],
        ),
      );
      if (reviewed != true || !mounted) return;
      await _openPrescription(request);
    }
    if (mounted)
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => QuotationEditor(
          repository: widget.repository,
          request: request,
          isPharmacist: widget.profile['role'] == 'pharmacist',
          deliveryAvailable: _delivery,
        ),
      );
    await _load();
  }

  Future<void> _editInventory({Map<String, dynamic>? existing}) async {
    final form = await showDialog<_InventoryFormData>(
      context: context,
      builder: (_) => InventoryEditor(existing: existing),
    );
    if (form == null) return;
    try {
      await widget.repository.saveInventoryItem(
        id: existing?['id'] as String?,
        name: form.name,
        strength: form.strength,
        formulation: form.formulation,
        quantity: form.quantity,
        unitPrice: form.unitPrice,
      );
      await _load();
    } catch (error) {
      _message(error.toString());
    }
  }

  String _formatDate(Object? value) {
    DateTime? date;
    if (value is Timestamp)
      date = value.toDate();
    else if (value is DateTime)
      date = value;
    return date == null
        ? 'unknown'
        : '${date.toLocal().year}-${date.toLocal().month.toString().padLeft(2, '0')}-${date.toLocal().day.toString().padLeft(2, '0')} ${date.toLocal().hour.toString().padLeft(2, '0')}:${date.toLocal().minute.toString().padLeft(2, '0')}';
  }
}

class _HoursSettingRow extends StatelessWidget {
  const _HoursSettingRow({
    required this.day,
    required this.hours,
    required this.onTap,
  });
  final int day;
  final PharmacyHours? hours;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return ListTile(
      dense: true,
      title: Text(days[day - 1]),
      subtitle: Text(
        hours?.open == true ? '${hours!.from}–${hours!.to}' : 'Closed',
      ),
      trailing: const Icon(Icons.edit, size: 18),
      onTap: onTap,
    );
  }
}

class _HoursEditor extends StatefulWidget {
  const _HoursEditor({required this.initial});
  final PharmacyHours initial;
  @override
  State<_HoursEditor> createState() => _HoursEditorState();
}

class _HoursEditorState extends State<_HoursEditor> {
  late bool _open = widget.initial.open;
  late String _from = widget.initial.from ?? '09:00';
  late String _to = widget.initial.to ?? '21:00';
  Future<void> _pick(bool start) async {
    final current = (start ? _from : _to).split(':');
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(current[0]),
        minute: int.parse(current[1]),
      ),
    );
    if (time == null) return;
    final value =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (start)
        _from = value;
      else
        _to = value;
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Operating hours'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          title: const Text('Open this day'),
          value: _open,
          onChanged: (value) => setState(() => _open = value),
        ),
        TextButton(
          onPressed: () => _pick(true),
          child: Text('Opens at $_from'),
        ),
        TextButton(
          onPressed: () => _pick(false),
          child: Text('Closes at $_to'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          PharmacyHours(open: _open, from: _from, to: _to),
        ),
        child: const Text('Save'),
      ),
    ],
  );
}

class _OperatingException {
  const _OperatingException({
    required this.date,
    required this.holiday,
    this.hours,
  });
  final String date;
  final bool holiday;
  final PharmacyHours? hours;
}

class _OperatingExceptionEditor extends StatefulWidget {
  const _OperatingExceptionEditor();
  @override
  State<_OperatingExceptionEditor> createState() =>
      _OperatingExceptionEditorState();
}

class _OperatingExceptionEditorState extends State<_OperatingExceptionEditor> {
  DateTime _date = DateTime.now();
  bool _holiday = true;
  bool _open = true;
  String _from = '09:00';
  String _to = '21:00';

  String get _dateKey =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _date,
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool start) async {
    final parts = (start ? _from : _to).split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (picked == null || !mounted) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (start) {
        _from = value;
      } else {
        _to = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Holiday or special date'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_today),
          label: Text(_dateKey),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Closed for the full day'),
          value: _holiday,
          onChanged: (value) => setState(() => _holiday = value),
        ),
        if (!_holiday) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Open on this date'),
            value: _open,
            onChanged: (value) => setState(() => _open = value),
          ),
          if (_open) ...[
            TextButton(
              onPressed: () => _pickTime(true),
              child: Text('Opens at $_from'),
            ),
            TextButton(
              onPressed: () => _pickTime(false),
              child: Text('Closes at $_to'),
            ),
          ],
        ],
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          _OperatingException(
            date: _dateKey,
            holiday: _holiday || !_open,
            hours: _holiday || !_open
                ? null
                : PharmacyHours(open: true, from: _from, to: _to),
          ),
        ),
        child: const Text('Save date'),
      ),
    ],
  );
}

class _InventoryFormData {
  const _InventoryFormData(
    this.name,
    this.strength,
    this.formulation,
    this.quantity,
    this.unitPrice,
  );
  final String name, strength, formulation;
  final int quantity;
  final double unitPrice;
}

class InventoryEditor extends StatefulWidget {
  const InventoryEditor({super.key, this.existing});
  final Map<String, dynamic>? existing;
  @override
  State<InventoryEditor> createState() => _InventoryEditorState();
}

class _InventoryEditorState extends State<InventoryEditor> {
  late final _name = TextEditingController(
    text: widget.existing?['medicineName'] as String? ?? '',
  );
  late final _strength = TextEditingController(
    text: widget.existing?['strength'] as String? ?? '',
  );
  late final _formulation = TextEditingController(
    text: widget.existing?['formulation'] as String? ?? 'Tablet',
  );
  late final _quantity = TextEditingController(
    text: '${widget.existing?['quantity'] ?? 0}',
  );
  late final _price = TextEditingController(
    text: '${widget.existing?['unitPrice'] ?? 0}',
  );
  @override
  void dispose() {
    _name.dispose();
    _strength.dispose();
    _formulation.dispose();
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.existing == null ? 'Add inventory item' : 'Update stock',
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Medicine name'),
          ),
          TextField(
            controller: _strength,
            decoration: const InputDecoration(labelText: 'Strength'),
          ),
          TextField(
            controller: _formulation,
            decoration: const InputDecoration(labelText: 'Formulation'),
          ),
          TextField(
            controller: _quantity,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Unit price (৳)'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final quantity = int.tryParse(_quantity.text);
          final price = double.tryParse(_price.text);
          if (quantity == null || price == null) return;
          Navigator.pop(
            context,
            _InventoryFormData(
              _name.text,
              _strength.text,
              _formulation.text,
              quantity,
              price,
            ),
          );
        },
        child: const Text('Save'),
      ),
    ],
  );
}

class QuotationEditor extends StatefulWidget {
  const QuotationEditor({
    super.key,
    required this.repository,
    required this.request,
    required this.isPharmacist,
    required this.deliveryAvailable,
  });
  final PharmacyRepository repository;
  final Map<String, dynamic> request;
  final bool isPharmacist;
  final bool deliveryAvailable;
  @override
  State<QuotationEditor> createState() => _QuotationEditorState();
}

class _QuotationEditorState extends State<QuotationEditor> {
  String _availability = 'available';
  final _deliveryFee = TextEditingController(text: '0');
  final _eta = TextEditingController(text: '45');
  final _notes = TextEditingController();
  final _unavailable = TextEditingController();
  late final List<_QuoteLine> _lines;
  bool _reviewed = false;
  bool _isAlternative = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _lines = [
      _QuoteLine(
        name: widget.request['type'] == 'availability'
            ? widget.request['medicineName'] as String? ?? ''
            : '',
        strength: widget.request['strength'] as String? ?? '',
        formulation: widget.request['formulation'] as String? ?? '',
        quantity: widget.request['quantity']?.toString() ?? '',
      ),
    ];
  }

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    _deliveryFee.dispose();
    _eta.dispose();
    _notes.dispose();
    _unavailable.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final requestedQty = (widget.request['quantity'] as num?)?.toInt() ?? 1;
    final activeLines = {'available', 'partial'}.contains(_availability)
        ? _lines
        : <_QuoteLine>[];
    final items = <Map<String, dynamic>>[];
    for (final line in activeLines) {
      final name = line.name.text.trim();
      final quantity = int.tryParse(line.quantity.text) ?? 0;
      final unitPrice = double.tryParse(line.unitPrice.text) ?? 0;
      if (name.isEmpty || quantity < 1 || unitPrice <= 0) {
        _show(
          'Enter a medicine, available quantity, and unit price for every quoted line.',
        );
        return;
      }
      items.add({
        'name': name,
        'strength': line.strength.text.trim(),
        'formulation': line.formulation.text.trim(),
        'quantity': quantity,
        'unitPrice': unitPrice,
        'total': quantity * unitPrice,
      });
    }
    final availableQty = items.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );
    if (_availability == 'available' &&
        widget.request['type'] == 'availability' &&
        availableQty < requestedQty) {
      _show('Enter the requested quantity or select Partially available.');
      return;
    }
    if (_availability == 'partial' &&
        widget.request['type'] == 'availability' &&
        availableQty >= requestedQty) {
      _show('The requested quantity is available. Select Available.');
      return;
    }
    if (_isAlternative && !widget.isPharmacist) {
      _show('Only a verified pharmacist can review an alternative medicine.');
      return;
    }
    setState(() => _busy = true);
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item['total'] as num).toDouble(),
    );
    try {
      await widget.repository.submitQuotation(
        requestId: widget.request['id'] as String,
        items: items,
        subtotal: subtotal,
        deliveryFee: double.tryParse(_deliveryFee.text) ?? 0,
        availability: _availability,
        estimatedMinutes: int.tryParse(_eta.text),
        notes: [
          if (_unavailable.text.trim().isNotEmpty)
            'Unavailable: ${_unavailable.text.trim()}',
          _notes.text.trim(),
        ].where((value) => value.isNotEmpty).join('\n'),
        prescriptionVerified: _reviewed,
        containsAlternative: _isAlternative,
        deliveryAvailable: widget.deliveryAvailable,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Quotation submitted.')));
      }
    } catch (error) {
      _show(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 18,
      bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.request['type'] == 'prescription'
                ? 'Create prescription quotation'
                : 'Respond to availability',
            style: AppTextStyles.headlineMedium,
          ),
          DropdownButtonFormField<String>(
            value: _availability,
            decoration: const InputDecoration(labelText: 'Availability'),
            items: const [
              DropdownMenuItem(value: 'available', child: Text('Available')),
              DropdownMenuItem(
                value: 'partial',
                child: Text('Partially available'),
              ),
              DropdownMenuItem(
                value: 'outOfStock',
                child: Text('Out of stock'),
              ),
              DropdownMenuItem(
                value: 'requiresReview',
                child: Text('Requires prescription review'),
              ),
            ],
            onChanged: (value) =>
                setState(() => _availability = value ?? 'available'),
          ),
          if ({'available', 'partial'}.contains(_availability)) ...[
            if (widget.request['type'] == 'prescription')
              const Text(
                'Add a separate price line for each medicine you can supply. Enter the same strength and formulation as the original prescription.',
              ),
            for (var index = 0; index < _lines.length; index++)
              _QuoteLineEditor(
                index: index,
                line: _lines[index],
                canRemove: _lines.length > 1,
                onRemove: () => setState(() {
                  _lines[index].dispose();
                  _lines.removeAt(index);
                }),
                prescriptionRequest: widget.request['type'] == 'prescription',
              ),
            if (widget.request['type'] == 'prescription')
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _lines.add(_QuoteLine())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add medicine line'),
                ),
              ),
          ],
          if (widget.request['type'] == 'availability')
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Offer an alternative medicine (patient must accept)',
              ),
              value: _isAlternative,
              onChanged: widget.isPharmacist
                  ? (value) => setState(() {
                      _isAlternative = value ?? false;
                      if (_isAlternative && _lines.isNotEmpty)
                        _lines.first.name.clear();
                    })
                  : null,
              subtitle: Text(
                widget.isPharmacist
                    ? 'A pharmacist must review the proposed medicine; the patient must separately accept it.'
                    : 'Alternative medicines require a verified pharmacist account.',
              ),
            ),
          TextField(
            controller: _deliveryFee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Delivery fee (৳)'),
          ),
          TextField(
            controller: _eta,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Estimated preparation/delivery time (minutes)',
            ),
          ),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notes for the patient',
            ),
          ),
          if (widget.request['type'] == 'prescription')
            TextField(
              controller: _unavailable,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Unavailable prescribed medicines (optional)',
              ),
            ),
          if (widget.request['type'] == 'prescription')
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'I am a verified pharmacist and reviewed the original prescription',
              ),
              value: _reviewed,
              onChanged: widget.isPharmacist
                  ? (value) => setState(() => _reviewed = value ?? false)
                  : null,
              subtitle: Text(
                widget.isPharmacist
                    ? 'Only check after reviewing the original. This is recorded with the quotation.'
                    : 'A pharmacist account must complete this check.',
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? 'Submitting…' : 'Submit quotation'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _QuoteLine {
  _QuoteLine({
    String name = '',
    String strength = '',
    String formulation = '',
    String quantity = '',
  }) : name = TextEditingController(text: name),
       strength = TextEditingController(text: strength),
       formulation = TextEditingController(text: formulation),
       quantity = TextEditingController(text: quantity);
  final TextEditingController name;
  final TextEditingController strength;
  final TextEditingController formulation;
  final TextEditingController quantity;
  final TextEditingController unitPrice = TextEditingController();
  void dispose() {
    name.dispose();
    strength.dispose();
    formulation.dispose();
    quantity.dispose();
    unitPrice.dispose();
  }
}

class _QuoteLineEditor extends StatelessWidget {
  const _QuoteLineEditor({
    required this.index,
    required this.line,
    required this.canRemove,
    required this.onRemove,
    required this.prescriptionRequest,
  });
  final int index;
  final _QuoteLine line;
  final bool canRemove;
  final VoidCallback onRemove;
  final bool prescriptionRequest;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Medicine line ${index + 1}',
                  style: AppTextStyles.bodyLarge,
                ),
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
            ],
          ),
          TextField(
            controller: line.name,
            decoration: InputDecoration(
              labelText: prescriptionRequest
                  ? 'Prescribed medicine name'
                  : 'Medicine name',
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: line.strength,
                  decoration: const InputDecoration(labelText: 'Strength'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: line.formulation,
                  decoration: const InputDecoration(labelText: 'Formulation'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: line.quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Available quantity',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: line.unitPrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Unit price (৳)',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class PrescriptionDocumentViewer extends StatefulWidget {
  const PrescriptionDocumentViewer({
    super.key,
    required this.bytes,
    required this.mimeType,
  });
  final Uint8List bytes;
  final String mimeType;
  @override
  State<PrescriptionDocumentViewer> createState() =>
      _PrescriptionDocumentViewerState();
}

class _PrescriptionDocumentViewerState
    extends State<PrescriptionDocumentViewer> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Original prescription')),
    body: widget.mimeType == 'application/pdf'
        ? PdfViewPinch(
            controller: PdfControllerPinch(
              document: PdfDocument.openData(widget.bytes),
            ),
          )
        : InteractiveViewer(
            child: Center(
              child: Image.memory(widget.bytes, fit: BoxFit.contain),
            ),
          ),
  );
}
