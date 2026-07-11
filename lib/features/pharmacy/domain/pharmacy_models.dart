import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

enum PharmacyVerification { pending, verified, rejected }

enum AvailabilityStatus { available, partial, outOfStock, requiresReview }

enum MedicineOrderStatus {
  pending,
  underReview,
  quoted,
  accepted,
  paymentPending,
  codSelected,
  confirmed,
  processing,
  dispatched,
  delivered,
  rejected,
  cancelled,
  expired,
}

String _stringValue(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

DateTime? _dateValue(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class PharmacyHours {
  const PharmacyHours({required this.open, this.from, this.to});

  final bool open;
  final String? from;
  final String? to;

  factory PharmacyHours.fromMap(Object? value) {
    if (value is! Map) return const PharmacyHours(open: false);
    return PharmacyHours(
      open: value['open'] == true,
      from: _stringValue(value['from'], ''),
      to: _stringValue(value['to'], ''),
    );
  }

  Map<String, dynamic> toMap() => {'open': open, 'from': from, 'to': to};
}

class Pharmacy {
  const Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.verification,
    required this.deliveryAvailable,
    required this.codAvailable,
    required this.weeklyHours,
    this.logoUrl,
    this.etaMinutes,
    this.temporaryClosed = false,
    this.holidays = const {},
    this.specialHours = const {},
    this.distanceKm,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final PharmacyVerification verification;
  final bool deliveryAvailable;
  final bool codAvailable;
  final Map<int, PharmacyHours> weeklyHours;
  final String? logoUrl;
  final int? etaMinutes;
  final bool temporaryClosed;
  final Set<String> holidays;
  final Map<String, PharmacyHours> specialHours;
  final double? distanceKm;

  bool get isVerified => verification == PharmacyVerification.verified;

  bool isOpenAt(DateTime instant) {
    if (temporaryClosed) return false;
    tz_data.initializeTimeZones();
    final dhakaTime = tz.TZDateTime.from(
      instant.toUtc(),
      tz.getLocation('Asia/Dhaka'),
    );
    final current = dhakaTime.hour * 60 + dhakaTime.minute;
    final todayKey = _dateKey(dhakaTime);
    final todayHours = _hoursForDate(dhakaTime);
    if (specialHours.containsKey(todayKey) || holidays.contains(todayKey)) {
      return _isOpenAtMinute(todayHours, current);
    }
    if (_isOpenAtMinute(todayHours, current)) return true;
    final yesterday = dhakaTime.subtract(const Duration(days: 1));
    final previousHours = _hoursForDate(yesterday);
    final previousStart = _minutes(previousHours?.from);
    final previousEnd = _minutes(previousHours?.to);
    return previousHours?.open == true &&
        previousStart != null &&
        previousEnd != null &&
        previousStart > previousEnd &&
        current < previousEnd;
  }

  PharmacyHours? _hoursForDate(DateTime date) {
    final key = _dateKey(date);
    if (specialHours.containsKey(key)) return specialHours[key];
    if (holidays.contains(key)) return const PharmacyHours(open: false);
    return weeklyHours[date.weekday];
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static bool _isOpenAtMinute(PharmacyHours? hours, int current) {
    if (hours?.open != true) return false;
    final start = _minutes(hours?.from);
    final end = _minutes(hours?.to);
    if (start == null || end == null || start == end) return false;
    return end > start ? current >= start && current < end : current >= start;
  }

  Pharmacy withDistance(double distance) => Pharmacy(
    id: id,
    name: name,
    address: address,
    phone: phone,
    latitude: latitude,
    longitude: longitude,
    verification: verification,
    deliveryAvailable: deliveryAvailable,
    codAvailable: codAvailable,
    weeklyHours: weeklyHours,
    logoUrl: logoUrl,
    etaMinutes: etaMinutes,
    temporaryClosed: temporaryClosed,
    holidays: holidays,
    specialHours: specialHours,
    distanceKm: distance,
  );

  factory Pharmacy.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final hoursMap = data['weeklyHours'] is Map
        ? data['weeklyHours'] as Map
        : const {};
    final weekly = <int, PharmacyHours>{};
    for (var day = 1; day <= 7; day++) {
      weekly[day] = PharmacyHours.fromMap(hoursMap['$day']);
    }
    final specialMap = data['specialHours'] is Map
        ? data['specialHours'] as Map
        : const {};
    return Pharmacy(
      id: doc.id,
      name: _stringValue(data['name'], 'Pharmacy'),
      address: _stringValue(data['address']),
      phone: _stringValue(data['phone']),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      verification: PharmacyVerification.values.firstWhere(
        (e) => e.name == data['verificationStatus'],
        orElse: () => PharmacyVerification.pending,
      ),
      deliveryAvailable: data['deliveryAvailable'] == true,
      codAvailable: data['codAvailable'] == true,
      weeklyHours: weekly,
      logoUrl: data['logoUrl'] as String?,
      etaMinutes: (data['etaMinutes'] as num?)?.toInt(),
      temporaryClosed: data['temporaryClosed'] == true,
      holidays: (data['holidays'] as List? ?? const [])
          .whereType<String>()
          .toSet(),
      specialHours: {
        for (final entry in specialMap.entries)
          if (entry.key is String)
            entry.key as String: PharmacyHours.fromMap(entry.value),
      },
    );
  }

  static int? _minutes(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }
}

double distanceInKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0088;
  final dLat = _radians(lat2 - lat1);
  final dLon = _radians(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_radians(lat1)) *
          math.cos(_radians(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _radians(double degrees) => degrees * math.pi / 180;

class MedicineAvailabilityRequest {
  const MedicineAvailabilityRequest({
    required this.id,
    required this.patientUid,
    required this.medicineName,
    required this.strength,
    required this.formulation,
    required this.quantity,
    required this.pharmacyIds,
    required this.expiresAt,
    required this.cancelled,
  });

  final String id;
  final String patientUid;
  final String medicineName;
  final String strength;
  final String formulation;
  final int quantity;
  final List<String> pharmacyIds;
  final DateTime? expiresAt;
  final bool cancelled;

  bool get isExpired =>
      cancelled || (expiresAt != null && expiresAt!.isBefore(DateTime.now()));

  factory MedicineAvailabilityRequest.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return MedicineAvailabilityRequest(
      id: doc.id,
      patientUid: _stringValue(data['patientUid']),
      medicineName: _stringValue(data['medicineName']),
      strength: _stringValue(data['strength']),
      formulation: _stringValue(data['formulation']),
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      pharmacyIds: (data['pharmacyIds'] as List? ?? const [])
          .whereType<String>()
          .toList(),
      expiresAt: _dateValue(data['expiresAt']),
      cancelled: data['cancelled'] == true,
    );
  }
}

class PharmacyQuotation {
  const PharmacyQuotation({
    required this.id,
    required this.requestId,
    required this.requestType,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.patientUid,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.availability,
    required this.estimatedMinutes,
    required this.deliveryAvailable,
    required this.stockConfirmedAt,
    required this.expiresAt,
    required this.notes,
    required this.requiresPrescriptionReview,
    required this.containsAlternative,
    required this.status,
    this.distanceKm,
  });

  final String id;
  final String requestId;
  final String requestType;
  final String pharmacyId;
  final String pharmacyName;
  final String patientUid;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double deliveryFee;
  final AvailabilityStatus availability;
  final int? estimatedMinutes;
  final bool deliveryAvailable;
  final DateTime? stockConfirmedAt;
  final DateTime? expiresAt;
  final String notes;
  final bool requiresPrescriptionReview;
  final bool containsAlternative;
  final String status;
  final double? distanceKm;

  double get total => subtotal + deliveryFee;

  factory PharmacyQuotation.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return PharmacyQuotation(
      id: doc.id,
      requestId: _stringValue(data['requestId']),
      requestType: _stringValue(data['requestType']),
      pharmacyId: _stringValue(data['pharmacyId']),
      pharmacyName: _stringValue(data['pharmacyName'], 'Pharmacy'),
      patientUid: _stringValue(data['patientUid']),
      items: (data['items'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0,
      availability: AvailabilityStatus.values.firstWhere(
        (e) => e.name == data['availability'],
        orElse: () => AvailabilityStatus.requiresReview,
      ),
      estimatedMinutes: (data['estimatedMinutes'] as num?)?.toInt(),
      deliveryAvailable: data['deliveryAvailable'] == true,
      stockConfirmedAt: _dateValue(data['stockConfirmedAt']),
      expiresAt: _dateValue(data['expiresAt']),
      notes: _stringValue(data['notes']),
      requiresPrescriptionReview: data['requiresPrescriptionReview'] == true,
      containsAlternative: data['containsAlternative'] == true,
      status: _stringValue(data['status'], 'submitted'),
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
    );
  }
}

class MedicineOrderStateMachine {
  const MedicineOrderStateMachine._();

  static const Map<MedicineOrderStatus, Set<MedicineOrderStatus>> transitions =
      {
        MedicineOrderStatus.pending: {
          MedicineOrderStatus.underReview,
          MedicineOrderStatus.rejected,
          MedicineOrderStatus.cancelled,
          MedicineOrderStatus.expired,
        },
        MedicineOrderStatus.underReview: {
          MedicineOrderStatus.quoted,
          MedicineOrderStatus.rejected,
          MedicineOrderStatus.cancelled,
          MedicineOrderStatus.expired,
        },
        MedicineOrderStatus.quoted: {
          MedicineOrderStatus.accepted,
          MedicineOrderStatus.cancelled,
          MedicineOrderStatus.expired,
        },
        MedicineOrderStatus.accepted: {
          MedicineOrderStatus.paymentPending,
          MedicineOrderStatus.codSelected,
          MedicineOrderStatus.cancelled,
        },
        MedicineOrderStatus.paymentPending: {
          MedicineOrderStatus.confirmed,
          MedicineOrderStatus.cancelled,
        },
        MedicineOrderStatus.codSelected: {
          MedicineOrderStatus.confirmed,
          MedicineOrderStatus.cancelled,
        },
        MedicineOrderStatus.confirmed: {
          MedicineOrderStatus.processing,
          MedicineOrderStatus.cancelled,
        },
        MedicineOrderStatus.processing: {
          MedicineOrderStatus.dispatched,
          MedicineOrderStatus.cancelled,
        },
        MedicineOrderStatus.dispatched: {MedicineOrderStatus.delivered},
        MedicineOrderStatus.delivered: {},
        MedicineOrderStatus.rejected: {},
        MedicineOrderStatus.cancelled: {},
        MedicineOrderStatus.expired: {},
      };

  static bool canTransition(MedicineOrderStatus from, MedicineOrderStatus to) =>
      transitions[from]!.contains(to);
}

class RefillEstimate {
  const RefillEstimate({required this.estimatedRunOut, required this.remindAt});
  final DateTime estimatedRunOut;
  final DateTime remindAt;

  static RefillEstimate? fromSupply({
    required double remainingQuantity,
    required double unitsPerDay,
    required DateTime asOf,
  }) {
    if (!remainingQuantity.isFinite ||
        !unitsPerDay.isFinite ||
        remainingQuantity <= 0 ||
        unitsPerDay <= 0) {
      return null;
    }
    final days = remainingQuantity / unitsPerDay;
    final runOut = asOf.add(Duration(minutes: (days * 24 * 60).ceil()));
    return RefillEstimate(
      estimatedRunOut: runOut,
      remindAt: runOut.subtract(const Duration(days: 2)),
    );
  }
}
