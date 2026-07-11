import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/permission_utils.dart';
import '../../data/pharmacy_repository.dart';
import '../../domain/pharmacy_models.dart';
import 'pharmacy_partner_page.dart';
import 'refills_tab.dart';

class MedicinePharmacyHomePage extends StatefulWidget {
  const MedicinePharmacyHomePage({super.key});

  @override
  State<MedicinePharmacyHomePage> createState() =>
      _MedicinePharmacyHomePageState();
}

class _MedicinePharmacyHomePageState extends State<MedicinePharmacyHomePage>
    with SingleTickerProviderStateMixin {
  final PharmacyRepository _repository = PharmacyRepository();
  late final TabController _tabs;
  final Set<String> _selectedIds = {};
  List<Pharmacy> _pharmacies = [];
  double _latitude = 23.8103;
  double _longitude = 90.4125;
  double _radius = 3;
  bool _hasUserLocation = false;
  bool _deliveryOnly = false;
  bool _isLoadingNearby = false;
  bool _showMap = false;
  String? _locationMessage = 'Set your location to find nearby pharmacies.';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingNearby = true);
    try {
      final allowed = await PermissionUtils.requestLocationPermission(context);
      if (!allowed) {
        setState(
          () => _locationMessage =
              'Location permission was declined. Choose a location on the map.',
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
      _hasUserLocation = true;
      _locationMessage = null;
      await _loadNearby();
    } catch (error) {
      setState(
        () => _locationMessage =
            'Could not get your location. Choose an area on the map.',
      );
    } finally {
      if (mounted) setState(() => _isLoadingNearby = false);
    }
  }

  Future<void> _chooseMapLocation() async {
    final location = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) =>
            LocationPickerPage(initial: LatLng(_latitude, _longitude)),
      ),
    );
    if (location == null || !mounted) return;
    setState(() {
      _latitude = location.latitude;
      _longitude = location.longitude;
      _hasUserLocation = false;
      _locationMessage = 'Using the map location you selected.';
    });
    await _loadNearby();
  }

  Future<void> _loadNearby() async {
    setState(() => _isLoadingNearby = true);
    try {
      final result = await _repository.findNearby(
        latitude: _latitude,
        longitude: _longitude,
        radiusKm: _radius,
        deliveryOnly: _deliveryOnly,
      );
      if (!mounted) return;
      setState(() {
        _pharmacies = result;
        _selectedIds.removeWhere(
          (id) => !_pharmacies.any((pharmacy) => pharmacy.id == id),
        );
        _locationMessage = result.isEmpty
            ? 'No verified pharmacies were found within ${_radius.toStringAsFixed(0)} km.'
            : null;
      });
    } catch (error) {
      if (mounted)
        setState(
          () => _locationMessage =
              'Pharmacy search is unavailable. Check your connection and Firebase setup.',
        );
    } finally {
      if (mounted) setState(() => _isLoadingNearby = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine & Pharmacy'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Nearby'),
            Tab(text: 'Availability'),
            Tab(text: 'My orders'),
            Tab(text: 'Refills'),
            Tab(text: 'Partner'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildNearbyTab(),
          AvailabilityTab(
            repository: _repository,
            pharmacies: _pharmacies,
            selectedIds: _selectedIds,
            latitude: _latitude,
            longitude: _longitude,
          ),
          OrdersTab(repository: _repository),
          RefillsTab(
            repository: _repository,
            pharmacies: _pharmacies,
            latitude: _latitude,
            longitude: _longitude,
          ),
          PharmacyPartnerPage(repository: _repository),
        ],
      ),
    );
  }

  Widget _buildNearbyTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isLoadingNearby ? null : _useCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: Text(
                        _hasUserLocation
                            ? 'Refresh my location'
                            : 'Use my location',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filledTonal(
                    onPressed: _chooseMapLocation,
                    tooltip: 'Choose location on map',
                    icon: const Icon(Icons.map_outlined),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => setState(() => _showMap = !_showMap),
                    tooltip: _showMap ? 'Show list' : 'Show map',
                    icon: Icon(_showMap ? Icons.list_alt : Icons.map),
                  ),
                ],
              ),
              if (_locationMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _locationMessage!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              Row(
                children: [
                  const Text('Radius'),
                  Expanded(
                    child: Slider(
                      value: _radius,
                      min: 2,
                      max: 5,
                      divisions: 3,
                      label: '${_radius.round()} km',
                      onChanged: (value) => setState(() => _radius = value),
                      onChangeEnd: (_) => _loadNearby(),
                    ),
                  ),
                  Text('${_radius.round()} km'),
                ],
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _deliveryOnly,
                title: const Text('Home delivery available'),
                onChanged: (value) {
                  setState(() => _deliveryOnly = value);
                  _loadNearby();
                },
              ),
            ],
          ),
        ),
        if (_selectedIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openPrescriptionComposer(),
                icon: const Icon(Icons.receipt_long),
                label: Text(
                  'Request prescription quotation (${_selectedIds.length}/4)',
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: _isLoadingNearby
              ? const Center(child: CircularProgressIndicator())
              : _showMap
              ? _buildMap()
              : _buildPharmacyList(),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(_latitude, _longitude),
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.aafiyah',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(_latitude, _longitude),
              width: 44,
              height: 44,
              child: const Icon(
                Icons.person_pin_circle,
                size: 40,
                color: AppColors.secondary,
              ),
            ),
            for (final pharmacy in _pharmacies)
              Marker(
                point: LatLng(pharmacy.latitude, pharmacy.longitude),
                width: 44,
                height: 52,
                child: GestureDetector(
                  onTap: () => _showPharmacyDetails(pharmacy),
                  child: const Icon(
                    Icons.local_pharmacy,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              '© OpenStreetMap contributors',
              onTap: () => launchUrl(
                Uri.parse('https://www.openstreetmap.org/copyright'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPharmacyList() {
    if (_pharmacies.isEmpty)
      return const Center(
        child: Text('No pharmacies to show yet. Set your location and search.'),
      );
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _pharmacies.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final pharmacy = _pharmacies[index];
        final selected = _selectedIds.contains(pharmacy.id);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: .15),
                      backgroundImage: pharmacy.logoUrl == null
                          ? null
                          : NetworkImage(pharmacy.logoUrl!),
                      child: pharmacy.logoUrl == null
                          ? const Icon(
                              Icons.local_pharmacy,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pharmacy.name,
                            style: AppTextStyles.headlineMedium,
                          ),
                          Text(
                            pharmacy.isOpenAt(DateTime.now())
                                ? 'Open now'
                                : 'Closed now',
                            style: TextStyle(
                              color: pharmacy.isOpenAt(DateTime.now())
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.verified,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const Text('Verified'),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(pharmacy.address),
                const SizedBox(height: 4),
                Text(
                  '${pharmacy.distanceKm?.toStringAsFixed(1) ?? '—'} km  ·  ${pharmacy.phone}',
                ),
                Text(
                  '${pharmacy.deliveryAvailable ? 'Delivery' : 'Pickup only'}  ·  ${pharmacy.codAvailable ? 'Cash on delivery' : 'COD unavailable'}${pharmacy.etaMinutes == null ? '' : '  ·  ~${pharmacy.etaMinutes} min'}',
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showPharmacyDetails(pharmacy),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          launchUrl(Uri.parse('tel:${pharmacy.phone}')),
                      icon: const Icon(Icons.call_outlined),
                      label: const Text('Call'),
                    ),
                    TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination=${pharmacy.latitude},${pharmacy.longitude}',
                        ),
                      ),
                      icon: const Icon(Icons.directions_outlined),
                      label: const Text('Directions'),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() {
                        if (selected) {
                          _selectedIds.remove(pharmacy.id);
                        } else if (_selectedIds.length < 4) {
                          _selectedIds.add(pharmacy.id);
                        }
                      }),
                      tooltip: selected
                          ? 'Remove selection'
                          : 'Select for prescription request',
                      icon: Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPharmacyDetails(Pharmacy pharmacy) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pharmacy.name, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(pharmacy.address),
            Text(pharmacy.phone),
            Text(
              'Open now: ${pharmacy.isOpenAt(DateTime.now()) ? 'Yes' : 'No'} · Bangladesh time',
            ),
            const SizedBox(height: 8),
            for (var day = 1; day <= 7; day++)
              _HoursRow(day: day, hours: pharmacy.weeklyHours[day]),
            const SizedBox(height: 12),
            Text(
              '${pharmacy.deliveryAvailable ? 'Home delivery available' : 'Home delivery not listed'} · ${pharmacy.codAvailable ? 'Cash on delivery' : 'COD not listed'}',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPrescriptionComposer() async {
    final selected = _pharmacies
        .where((p) => _selectedIds.contains(p.id))
        .toList();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrescriptionRequestPage(
          repository: _repository,
          pharmacies: selected,
          latitude: _latitude,
          longitude: _longitude,
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({required this.day, required this.hours});
  final int day;
  final PharmacyHours? hours;

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Text(
      '${days[day - 1]}  ·  ${hours?.open == true ? '${hours!.from}–${hours!.to}' : 'Closed'}',
    );
  }
}

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, required this.initial});
  final LatLng initial;
  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late LatLng _center = widget.initial;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Choose search location')),
    body: Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: widget.initial,
            initialZoom: 13,
            onPositionChanged: (position, _) {
              final center = position.center;
              setState(() => _center = center);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.aafiyah',
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        const Center(
          child: Icon(Icons.location_pin, size: 48, color: Colors.redAccent),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: FilledButton.icon(
            onPressed: () => Navigator.pop(context, _center),
            icon: const Icon(Icons.check),
            label: const Text('Use this map location'),
          ),
        ),
      ],
    ),
  );
}

class PrescriptionRequestPage extends StatefulWidget {
  const PrescriptionRequestPage({
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
  State<PrescriptionRequestPage> createState() =>
      _PrescriptionRequestPageState();
}

class _PrescriptionRequestPageState extends State<PrescriptionRequestPage> {
  Uint8List? _bytes;
  Uint8List? _originalBytes;
  String? _fileName;
  String? _mimeType;
  bool _hasEditedPreview = false;
  String? _ocrText;
  bool _isBusy = false;
  String? _result;
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _prescriber = TextEditingController();
  final _instructions = TextEditingController();
  DateTime? _prescriptionDate;
  DateTime? _reportedExpiry;

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    _prescriber.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _pickPdfOrImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return;
    if (file.bytes == null) {
      _toast('Could not read the selected file.');
      return;
    }
    setState(() {
      _bytes = file.bytes;
      _originalBytes = file.bytes;
      _fileName = file.name;
      _mimeType = _mimeFor(file.name);
      _ocrText = null;
      _hasEditedPreview = false;
    });
  }

  Future<void> _capturePrescription({
    ImageSource source = ImageSource.camera,
  }) async {
    final selected = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 2400,
    );
    if (selected == null) return;
    final originalBytes = await selected.readAsBytes();
    final cropped = await ImageCropper().cropImage(
      sourcePath: selected.path,
      compressQuality: 92,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop prescription',
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop prescription'),
        WebUiSettings(context: context),
      ],
    );
    final bytes = cropped == null
        ? originalBytes
        : await XFile(cropped.path).readAsBytes();
    setState(() {
      _bytes = bytes;
      _originalBytes = originalBytes;
      _fileName = 'prescription.jpg';
      _mimeType = 'image/jpeg';
      _ocrText = null;
      _hasEditedPreview = cropped != null;
    });
  }

  Future<void> _readOnDevice() async {
    if (_originalBytes == null || _mimeType == 'application/pdf') {
      _toast('On-device text extraction is available for images.');
      return;
    }
    if (kIsWeb) {
      _toast('On-device OCR is available in the Android and iOS apps.');
      return;
    }
    setState(() => _isBusy = true);
    try {
      // OCR is run only on the image already selected by the user. It is never
      // sent to an AI service. Uploaded bytes remain the source of truth.
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/aafiyah-prescription-ocr.jpg');
      await file.writeAsBytes(_originalBytes!, flush: true);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(
        InputImage.fromFilePath(file.path),
      );
      await recognizer.close();
      if (!mounted) return;
      setState(() => _ocrText = result.text.trim());
    } catch (_) {
      _toast(
        'Text extraction could not read this image. You can still send the original for pharmacist review.',
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _submit() async {
    if (_bytes == null ||
        _originalBytes == null ||
        _fileName == null ||
        _mimeType == null) {
      _toast('Choose a prescription first.');
      return;
    }
    if (widget.pharmacies.isEmpty) {
      _toast('Select a verified nearby pharmacy first.');
      return;
    }
    setState(() => _isBusy = true);
    try {
      final id = await widget.repository.uploadPrescriptionRequest(
        fileName: _fileName!,
        mimeType: _mimeType!,
        bytes: _originalBytes!,
        reviewCopyBytes: _hasEditedPreview ? _bytes : null,
        pharmacyIds: widget.pharmacies.map((p) => p.id).toList(),
        address: _address.text,
        contactNumber: _phone.text,
        instructions: _instructions.text,
        latitude: widget.latitude,
        longitude: widget.longitude,
        patientProvidedPrescriber: _prescriber.text,
        patientProvidedWrittenDate:
            _prescriptionDate?.toIso8601String().split('T').first ?? '',
        patientProvidedExpiryDate:
            _reportedExpiry?.toIso8601String().split('T').first ?? '',
      );
      if (mounted) setState(() => _result = id);
    } catch (error) {
      _toast(error.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _toast(String message) {
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickPrescriptionDate({required bool written}) async {
    final now = DateTime.now();
    final initial = written
        ? (_prescriptionDate ?? now)
        : (_reportedExpiry ?? now.add(const Duration(days: 365)));
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 30),
      initialDate: initial,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (written) {
        _prescriptionDate = picked;
      } else {
        _reportedExpiry = picked;
      }
    });
  }

  String _dateLabel(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_result != null)
      return Scaffold(
        appBar: AppBar(title: const Text('Request submitted')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your prescription request was sent to the selected pharmacies.',
                ),
                const SizedBox(height: 8),
                Text('Request ID: $_result', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 12),
                const Text(
                  'The original prescription is preserved. A qualified pharmacist must verify it before fulfillment.',
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription request')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Text(
            'Send your prescription to pharmacies',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Images are uploaded privately. Local text extraction is only an aid; the original document remains the source of truth.',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isBusy ? null : _pickPdfOrImage,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Choose image or PDF'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isBusy ? null : _capturePrescription,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan with camera'),
                ),
              ),
            ],
          ),
          if (_bytes != null) ...[
            const SizedBox(height: AppSpacing.md),
            _mimeType == 'application/pdf'
                ? SizedBox(
                    height: 360,
                    child: PdfViewPinch(
                      controller: PdfControllerPinch(
                        document: PdfDocument.openData(_bytes!),
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _bytes!,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
            Text(_fileName ?? '', textAlign: TextAlign.center),
            if (_hasEditedPreview)
              const Text(
                'Edited preview · the unedited source is stored separately and remains the review source.',
              ),
            if (_mimeType != 'application/pdf')
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isBusy ? null : _cropSelected,
                    icon: const Icon(Icons.crop_rotate),
                    label: const Text('Crop or rotate'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isBusy ? null : _readOnDevice,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text('Read text on this device'),
                  ),
                ],
              ),
          ],
          if (_ocrText != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unverified text extraction',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Review this text; it is not a medical instruction. A pharmacist must verify medicines and directions.',
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _ocrText!.isEmpty ? 'No text was recognized.' : _ocrText!,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Selected pharmacies (${widget.pharmacies.length}/4)',
            style: AppTextStyles.headlineMedium,
          ),
          for (final pharmacy in widget.pharmacies)
            ListTile(
              dense: true,
              leading: const Icon(Icons.verified, color: AppColors.primary),
              title: Text(pharmacy.name),
              subtitle: Text(
                '${pharmacy.distanceKm?.toStringAsFixed(1) ?? '—'} km · ${pharmacy.isOpenAt(DateTime.now()) ? 'Open' : 'Closed'}',
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _address,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Delivery address',
              prefixIcon: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Contact number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _prescriber,
            decoration: const InputDecoration(
              labelText: 'Prescriber name (optional; patient-entered)',
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => _pickPrescriptionDate(written: true),
                icon: const Icon(Icons.event),
                label: Text(
                  _prescriptionDate == null
                      ? 'Prescription date'
                      : 'Written ${_dateLabel(_prescriptionDate!)}',
                ),
              ),
              TextButton.icon(
                onPressed: () => _pickPrescriptionDate(written: false),
                icon: const Icon(Icons.event_busy),
                label: Text(
                  _reportedExpiry == null
                      ? 'Reported expiry'
                      : 'Expires ${_dateLabel(_reportedExpiry!)}',
                ),
              ),
            ],
          ),
          const Text(
            'These details are patient-entered and must be checked against the original by a pharmacist.',
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _instructions,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Instructions for pharmacies (optional)',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Request expires after 24 hours. Pharmacies receive only your request. The prescription file is accessible only to you and the selected verified pharmacies.',
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _isBusy ? null : _submit,
            icon: _isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: const Text('Send prescription request'),
          ),
        ],
      ),
    );
  }

  String _mimeFor(String filename) {
    final name = filename.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }

  Future<void> _cropSelected() async {
    if (kIsWeb || _bytes == null || _mimeType == 'application/pdf') {
      _toast(
        'Image crop and rotate are available in the Android and iOS apps.',
      );
      return;
    }
    setState(() => _isBusy = true);
    try {
      final directory = await getTemporaryDirectory();
      final suffix = _mimeType == 'image/png' ? 'png' : 'jpg';
      final input = File('${directory.path}/aafiyah-prescription-crop.$suffix');
      await input.writeAsBytes(_bytes!, flush: true);
      final output = await ImageCropper().cropImage(
        sourcePath: input.path,
        compressQuality: 92,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop prescription',
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop prescription'),
          WebUiSettings(context: context),
        ],
      );
      if (output != null && mounted) {
        final bytes = await File(output.path).readAsBytes();
        setState(() {
          _bytes = bytes;
          _hasEditedPreview = true;
        });
      }
    } catch (_) {
      _toast('Could not edit this image. Please choose or capture it again.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }
}

class AvailabilityTab extends StatefulWidget {
  const AvailabilityTab({
    super.key,
    required this.repository,
    required this.pharmacies,
    required this.selectedIds,
    required this.latitude,
    required this.longitude,
  });
  final PharmacyRepository repository;
  final List<Pharmacy> pharmacies;
  final Set<String> selectedIds;
  final double latitude;
  final double longitude;
  @override
  State<AvailabilityTab> createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<AvailabilityTab> {
  final _name = TextEditingController();
  final _strength = TextEditingController();
  final _formulation = TextEditingController(text: 'Tablet');
  final _quantity = TextEditingController(text: '1');
  String? _requestId;
  bool _busy = false;
  @override
  void dispose() {
    _name.dispose();
    _strength.dispose();
    _formulation.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _createRequest() async {
    final ids = widget.selectedIds.toList();
    if (ids.isEmpty || ids.length > 4) {
      _notice('Choose one to four pharmacies in the Nearby tab.');
      return;
    }
    setState(() => _busy = true);
    try {
      // Requests must use the patient's manually selected/current map location.
      final id = await widget.repository.createAvailabilityRequest(
        medicineName: _name.text,
        strength: _strength.text,
        formulation: _formulation.text,
        quantity: int.tryParse(_quantity.text) ?? 0,
        pharmacyIds: ids,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (mounted) setState(() => _requestId = id);
    } catch (error) {
      _notice(error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.md),
    children: [
      const Text(
        'Check medicine availability',
        style: AppTextStyles.headlineMedium,
      ),
      const Text(
        'Send one request to up to four selected pharmacies. Stock details expire after 30 minutes and are timestamped by the pharmacy.',
      ),
      const SizedBox(height: AppSpacing.md),
      TextField(
        controller: _name,
        decoration: const InputDecoration(labelText: 'Medicine name'),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _strength,
        decoration: const InputDecoration(labelText: 'Strength (optional)'),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _formulation,
              decoration: const InputDecoration(labelText: 'Formulation'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        'Sending to ${widget.selectedIds.length} pharmacies: ${widget.pharmacies.where((p) => widget.selectedIds.contains(p.id)).map((p) => p.name).join(', ')}',
      ),
      FilledButton.icon(
        onPressed: _busy ? null : _createRequest,
        icon: const Icon(Icons.search),
        label: Text(_busy ? 'Sending…' : 'Send availability request'),
      ),
      if (_requestId != null) ...[
        const SizedBox(height: 12),
        Text(
          'Request $_requestId is active. Responses will appear here as pharmacies reply.',
        ),
        StreamBuilder<List<PharmacyQuotation>>(
          stream: widget.repository.watchQuotes(_requestId!),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            if (snapshot.data!.isEmpty)
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Waiting for pharmacy responses…'),
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
}

class QuoteComparisonTable extends StatelessWidget {
  const QuoteComparisonTable({super.key, required this.quotes});
  final List<PharmacyQuotation> quotes;

  String _stockTime(DateTime? value) {
    if (value == null) return '—';
    tz_data.initializeTimeZones();
    final dhaka = tz.TZDateTime.from(
      value.toUtc(),
      tz.getLocation('Asia/Dhaka'),
    );
    final date =
        '${dhaka.day.toString().padLeft(2, '0')}/${dhaka.month.toString().padLeft(2, '0')}';
    final time =
        '${dhaka.hour.toString().padLeft(2, '0')}:${dhaka.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compare quotations', style: AppTextStyles.headlineMedium),
          const Text('Stock confirmation times are shown in Bangladesh time.'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Pharmacy')),
                DataColumn(label: Text('Availability')),
                DataColumn(label: Text('Qty')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Distance')),
                DataColumn(label: Text('Delivery')),
                DataColumn(label: Text('ETA')),
                DataColumn(label: Text('Stock checked (BDT)')),
              ],
              rows: [
                for (final quote in quotes)
                  DataRow(
                    cells: [
                      DataCell(Text(quote.pharmacyName)),
                      DataCell(Text(quote.availability.name)),
                      DataCell(
                        Text(
                          quote.items
                              .fold<int>(
                                0,
                                (sum, item) =>
                                    sum +
                                    ((item['quantity'] as num?)?.toInt() ?? 0),
                              )
                              .toString(),
                        ),
                      ),
                      DataCell(Text('৳${quote.total.toStringAsFixed(2)}')),
                      DataCell(
                        Text(
                          quote.distanceKm == null
                              ? '—'
                              : '${quote.distanceKm!.toStringAsFixed(1)} km',
                        ),
                      ),
                      DataCell(Text(quote.deliveryAvailable ? 'Yes' : 'No')),
                      DataCell(
                        Text(
                          quote.estimatedMinutes == null
                              ? '—'
                              : '${quote.estimatedMinutes} min',
                        ),
                      ),
                      DataCell(Text(_stockTime(quote.stockConfirmedAt))),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class QuoteCard extends StatefulWidget {
  const QuoteCard({super.key, required this.quote, required this.repository});
  final PharmacyQuotation quote;
  final PharmacyRepository repository;
  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  bool _acceptAlternative = false;
  bool _busy = false;
  Future<void> _order() async {
    setState(() => _busy = true);
    try {
      final id = await widget.repository.confirmCodOrder(
        quote: widget.quote,
        acceptAlternative: _acceptAlternative,
      );
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order $id confirmed with cash on delivery.')),
        );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final stockTime = quote.stockConfirmedAt == null
        ? 'Time unavailable'
        : MaterialLocalizations.of(
            context,
          ).formatMediumDate(quote.stockConfirmedAt!.toLocal());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quote.pharmacyName, style: AppTextStyles.headlineMedium),
            Text(
              '${quote.availability.name} · ${quote.estimatedMinutes == null ? 'ETA unavailable' : '${quote.estimatedMinutes} min'} · confirmed $stockTime',
            ),
            for (final item in quote.items)
              Text(
                '${item['name'] ?? 'Medicine'} ${item['strength'] ?? ''} · qty ${item['quantity'] ?? '—'} · ৳${item['total'] ?? item['unitPrice'] ?? '—'}',
              ),
            Text(
              'Items ৳${quote.subtotal.toStringAsFixed(2)} · delivery ৳${quote.deliveryFee.toStringAsFixed(2)} · total ৳${quote.total.toStringAsFixed(2)}',
            ),
            if (quote.notes.isNotEmpty) Text('Pharmacy note: ${quote.notes}'),
            if (quote.requiresPrescriptionReview)
              const Text(
                'Waiting for pharmacist verification.',
                style: TextStyle(color: AppColors.warning),
              ),
            if (!quote.deliveryAvailable)
              const Text(
                'Home delivery is unavailable for this quotation. Contact the pharmacy for collection details.',
              ),
            if (quote.containsAlternative)
              CheckboxListTile(
                value: _acceptAlternative,
                onChanged: (value) =>
                    setState(() => _acceptAlternative = value ?? false),
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'I explicitly accept the proposed alternative medicine',
                ),
              ),
            if (quote.status == 'submitted' &&
                quote.deliveryAvailable &&
                quote.availability != AvailabilityStatus.outOfStock)
              FilledButton(
                onPressed: _busy ? null : _order,
                child: Text(
                  _busy ? 'Confirming…' : 'Confirm order · cash on delivery',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key, required this.repository});
  final PharmacyRepository repository;
  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  late Future<List<Map<String, dynamic>>> _future;
  @override
  void initState() {
    super.initState();
    _future = widget.repository.listOrders();
  }

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<Map<String, dynamic>>>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return const Center(child: CircularProgressIndicator());
      if (snapshot.hasError)
        return Center(
          child: Text('Sign in to view your orders. ${snapshot.error}'),
        );
      if (snapshot.data!.isEmpty)
        return const Center(
          child: Text('Your medicine orders will appear here.'),
        );
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final order in snapshot.data!)
            Card(
              child: ListTile(
                leading: const Icon(Icons.medication, color: AppColors.primary),
                title: Text(order['pharmacyName'] as String? ?? 'Pharmacy'),
                subtitle: Text(
                  '${order['status']} · ৳${order['total']} · Cash on delivery',
                ),
                trailing: Text('#${(order['id'] as String).substring(0, 6)}'),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['pharmacyName'] as String? ?? 'Pharmacy',
                          style: AppTextStyles.headlineMedium,
                        ),
                        Text('Status: ${order['status']}'),
                        Text('Total: ৳${order['total']}'),
                        Text(
                          'Delivery address: ${order['deliveryAddress'] ?? 'Pickup'}',
                        ),
                        const SizedBox(height: 12),
                        if ({
                          'confirmed',
                          'processing',
                        }.contains(order['status']))
                          FilledButton(
                            onPressed: () async {
                              await widget.repository.updateOrderStatus(
                                order['id'] as String,
                                MedicineOrderStatus.cancelled,
                              );
                              if (context.mounted) Navigator.pop(context);
                              setState(
                                () => _future = widget.repository.listOrders(),
                              );
                            },
                            child: const Text('Cancel order'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
