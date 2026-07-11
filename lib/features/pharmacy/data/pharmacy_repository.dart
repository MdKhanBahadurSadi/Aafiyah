import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../domain/pharmacy_models.dart';

class MedicineCommerceException implements Exception {
  const MedicineCommerceException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Firebase-backed repository for pharmacy discovery, prescription requests,
/// availability checks, quotations, and confirmed COD orders.
class PharmacyRepository {
  PharmacyRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null)
      throw const MedicineCommerceException(
        'Sign in to use medicine ordering.',
      );
    return user.uid;
  }

  /// Firestore is queried by a bounding box using range indexes, then exact
  /// great-circle distance is calculated for the small candidate set.
  Future<List<Pharmacy>> findNearby({
    required double latitude,
    required double longitude,
    required double radiusKm,
    bool deliveryOnly = false,
    int limit = 50,
  }) async {
    if (radiusKm < 1 || radiusKm > 20)
      throw const MedicineCommerceException('Choose a radius from 1 to 20 km.');
    final latDelta = radiusKm / 110.574;
    final cosLat = math.cos(latitude * math.pi / 180).abs().clamp(0.05, 1.0);
    final lonDelta = radiusKm / (111.320 * cosLat);
    final minLat = (latitude - latDelta).clamp(-90.0, 90.0);
    final maxLat = (latitude + latDelta).clamp(-90.0, 90.0);
    final minLon = (longitude - lonDelta).clamp(-180.0, 180.0);
    final maxLon = (longitude + lonDelta).clamp(-180.0, 180.0);

    Query<Map<String, dynamic>> query = _db
        .collection('pharmacies')
        .where('verificationStatus', isEqualTo: 'verified')
        .where('latitude', isGreaterThanOrEqualTo: minLat)
        .where('latitude', isLessThanOrEqualTo: maxLat)
        .where('longitude', isGreaterThanOrEqualTo: minLon)
        .where('longitude', isLessThanOrEqualTo: maxLon);
    if (deliveryOnly) query = query.where('deliveryAvailable', isEqualTo: true);
    final snapshot = await query.limit(limit).get();
    final results =
        snapshot.docs
            .map(Pharmacy.fromDocument)
            .map((p) {
              return p.withDistance(
                distanceInKm(latitude, longitude, p.latitude, p.longitude),
              );
            })
            .where((p) => p.distanceKm! <= radiusKm)
            .toList()
          ..sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
    return results;
  }

  Future<String> createAvailabilityRequest({
    required String medicineName,
    required String strength,
    required String formulation,
    required int quantity,
    required List<String> pharmacyIds,
    required double latitude,
    required double longitude,
  }) async {
    final uid = _uid;
    final name = medicineName.trim();
    if (name.isEmpty || quantity < 1 || quantity > 10000) {
      throw const MedicineCommerceException(
        'Enter a medicine name and a valid quantity.',
      );
    }
    _validatePharmacySelection(pharmacyIds);
    final ref = _db.collection('pharmacyRequests').doc();
    final now = DateTime.now().toUtc();
    await ref.set({
      'patientUid': uid,
      'type': 'availability',
      'medicineName': name,
      'medicineNameNormalized': name.toLowerCase(),
      'strength': strength.trim(),
      'formulation': formulation.trim(),
      'quantity': quantity,
      'pharmacyIds': pharmacyIds,
      'latitude': latitude,
      'longitude': longitude,
      'status': 'pending',
      'cancelled': false,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(minutes: 30))),
    });
    return ref.id;
  }

  Future<MedicineAvailabilityRequest> getAvailabilityRequest(String id) async {
    final snapshot = await _db.collection('pharmacyRequests').doc(id).get();
    if (!snapshot.exists || snapshot.data()?['patientUid'] != _uid) {
      throw const MedicineCommerceException(
        'Availability request was not found.',
      );
    }
    return MedicineAvailabilityRequest.fromDocument(snapshot);
  }

  Stream<List<PharmacyQuotation>> watchQuotes(String requestId) {
    final uid = _uid;
    return _db
        .collection('pharmacyQuotes')
        .where('requestId', isEqualTo: requestId)
        .where('patientUid', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(PharmacyQuotation.fromDocument).toList(),
        );
  }

  Future<List<Map<String, dynamic>>> listMyRequests() async {
    final snapshot = await _db
        .collection('pharmacyRequests')
        .where('patientUid', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> cancelRequest(String requestId) async {
    final uid = _uid;
    final ref = _db.collection('pharmacyRequests').doc(requestId);
    await _db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final data = doc.data();
      if (data == null || data['patientUid'] != uid)
        throw const MedicineCommerceException('Request not found.');
      if (data['status'] == 'accepted' ||
          data['status'] == 'cancelled' ||
          data['status'] == 'expired') {
        throw const MedicineCommerceException(
          'This request can no longer be cancelled.',
        );
      }
      tx.update(ref, {
        'status': 'cancelled',
        'cancelled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (data['type'] == 'prescription' && data['prescriptionId'] is String) {
        for (final pharmacyId
            in (data['pharmacyIds'] as List? ?? const []).whereType<String>()) {
          tx.update(
            _db
                .collection('prescriptionShares')
                .doc('${uid}_${data['prescriptionId']}_$pharmacyId'),
            {'allowed': false},
          );
        }
      }
    });
  }

  Future<String> uploadPrescriptionRequest({
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    Uint8List? reviewCopyBytes,
    required List<String> pharmacyIds,
    required String address,
    required String contactNumber,
    required String instructions,
    required double latitude,
    required double longitude,
    String patientProvidedPrescriber = '',
    String patientProvidedWrittenDate = '',
    String patientProvidedExpiryDate = '',
  }) async {
    final uid = _uid;
    _validatePharmacySelection(pharmacyIds);
    final lowerName = fileName.toLowerCase();
    final supported = <String, String>{
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.pdf': 'application/pdf',
    };
    final extension = supported.keys.firstWhere(
      (ext) => lowerName.endsWith(ext),
      orElse: () => '',
    );
    if (extension.isEmpty ||
        supported[extension] != mimeType.toLowerCase() ||
        !_matchesFileSignature(bytes, mimeType)) {
      throw const MedicineCommerceException(
        'Use a JPG, JPEG, PNG, or PDF prescription file.',
      );
    }
    if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
      throw const MedicineCommerceException(
        'Prescription files must be smaller than 10 MB.',
      );
    }
    if (address.trim().isEmpty || contactNumber.trim().isEmpty) {
      throw const MedicineCommerceException(
        'Add a delivery address and contact number.',
      );
    }

    final prescriptions = _db.collection('prescriptions');
    final prescriptionRef = prescriptions.doc();
    final requestRef = _db.collection('pharmacyRequests').doc();
    final storagePath =
        'prescriptions/$uid/${prescriptionRef.id}/original$extension';
    final storageRef = _storage.ref(storagePath);
    final reviewPath = reviewCopyBytes == null
        ? null
        : 'prescriptions/$uid/${prescriptionRef.id}/review-copy.jpg';
    final reviewRef = reviewPath == null ? null : _storage.ref(reviewPath);
    try {
      await storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: mimeType,
          customMetadata: {
            'patientUid': uid,
            'prescriptionId': prescriptionRef.id,
          },
        ),
      );
      if (reviewRef != null && reviewCopyBytes != null) {
        if (reviewCopyBytes.isEmpty ||
            reviewCopyBytes.length > 10 * 1024 * 1024 ||
            !_matchesFileSignature(reviewCopyBytes, 'image/jpeg')) {
          throw const MedicineCommerceException(
            'The edited prescription preview is invalid.',
          );
        }
        await reviewRef.putData(
          reviewCopyBytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'patientUid': uid,
              'prescriptionId': prescriptionRef.id,
              'derivativeOf': storagePath,
            },
          ),
        );
      }
      final batch = _db.batch();
      batch.set(prescriptionRef, {
        'patientUid': uid,
        'storagePath': storagePath,
        'reviewCopyStoragePath': reviewPath,
        'fileName': fileName,
        'mimeType': mimeType,
        'fileSize': bytes.length,
        'status': 'original_received',
        'ocrStatus': 'not_processed',
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(requestRef, {
        'patientUid': uid,
        'type': 'prescription',
        'prescriptionId': prescriptionRef.id,
        'pharmacyIds': pharmacyIds,
        'deliveryAddress': address.trim(),
        'contactNumber': contactNumber.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'instructions': instructions.trim(),
        'patientProvidedPrescriber': patientProvidedPrescriber.trim(),
        'patientProvidedWrittenDate': patientProvidedWrittenDate.trim(),
        'patientProvidedExpiryDate': patientProvidedExpiryDate.trim(),
        'status': 'pending',
        'cancelled': false,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().toUtc().add(const Duration(hours: 24)),
        ),
      });
      for (final pharmacyId in pharmacyIds) {
        batch.set(
          _db
              .collection('prescriptionShares')
              .doc('${uid}_${prescriptionRef.id}_$pharmacyId'),
          {
            'patientUid': uid,
            'prescriptionId': prescriptionRef.id,
            'requestId': requestRef.id,
            'pharmacyId': pharmacyId,
            'allowed': true,
            'accessUntil': Timestamp.fromDate(
              DateTime.now().toUtc().add(const Duration(days: 7)),
            ),
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }
      await batch.commit();
      return requestRef.id;
    } catch (error) {
      try {
        await storageRef.delete();
      } catch (_) {
        /* Upload may not have completed. */
      }
      if (reviewRef != null) {
        try {
          await reviewRef.delete();
        } catch (_) {
          /* Upload may not have completed. */
        }
      }
      rethrow;
    }
  }

  Future<Uint8List> readPrescription(String storagePath) async {
    final data = await _storage.ref(storagePath).getData(10 * 1024 * 1024);
    if (data == null)
      throw const MedicineCommerceException(
        'Prescription file could not be downloaded.',
      );
    return data;
  }

  Future<Map<String, dynamic>?> pharmacyForCurrentUser() async {
    final membership = await _db.collection('pharmacyUsers').doc(_uid).get();
    if (!membership.exists) return null;
    final pharmacyId = membership.data()?['pharmacyId'] as String?;
    if (pharmacyId == null) return null;
    final profile = await _db.collection('pharmacies').doc(pharmacyId).get();
    return {
      'id': pharmacyId,
      'membershipStatus': membership.data()?['status'],
      'role': membership.data()?['role'],
      ...?profile.data(),
    };
  }

  Future<Map<String, dynamic>> getPrescriptionForRequest(
    Map<String, dynamic> request,
  ) async {
    final uid = _uid;
    final prescriptionId = request['prescriptionId'] as String?;
    if (prescriptionId == null)
      throw const MedicineCommerceException(
        'Prescription details are unavailable.',
      );
    final snapshot = await _db
        .collection('prescriptions')
        .doc(prescriptionId)
        .get();
    if (!snapshot.exists)
      throw const MedicineCommerceException(
        'Prescription record was not found.',
      );
    final data = snapshot.data()!;
    if (data['patientUid'] != request['patientUid'] ||
        request['type'] != 'prescription') {
      throw const MedicineCommerceException(
        'Prescription access is not authorized.',
      );
    }
    return {
      'id': snapshot.id,
      ...data,
      'requestPatientUid': request['patientUid'],
      'viewerUid': uid,
    };
  }

  Future<String> registerPharmacy({
    required String name,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required String licenseNumber,
    required Uint8List licenseBytes,
    required String licenseFileName,
    required String licenseMimeType,
  }) async {
    final uid = _uid;
    final existing = await _db.collection('pharmacyUsers').doc(uid).get();
    if (existing.exists)
      throw const MedicineCommerceException(
        'This account already has a pharmacy profile.',
      );
    if (name.trim().isEmpty ||
        address.trim().isEmpty ||
        phone.trim().isEmpty ||
        licenseNumber.trim().isEmpty) {
      throw const MedicineCommerceException(
        'Complete the pharmacy business and license details.',
      );
    }
    if (licenseBytes.isEmpty ||
        licenseBytes.length > 10 * 1024 * 1024 ||
        !{
          'application/pdf',
          'image/jpeg',
          'image/png',
        }.contains(licenseMimeType) ||
        !_matchesFileSignature(licenseBytes, licenseMimeType)) {
      throw const MedicineCommerceException(
        'Attach a PDF, JPG, or PNG license document smaller than 10 MB.',
      );
    }
    final extension = licenseMimeType == 'application/pdf'
        ? 'pdf'
        : licenseMimeType == 'image/png'
        ? 'png'
        : 'jpg';
    final pharmacy = _db.collection('pharmacies').doc();
    final storagePath =
        'pharmacy-verifications/$uid/${pharmacy.id}/license.$extension';
    final licenseRef = _storage.ref(storagePath);
    await licenseRef.putData(
      licenseBytes,
      SettableMetadata(
        contentType: licenseMimeType,
        customMetadata: {'pharmacyId': pharmacy.id, 'ownerUid': uid},
      ),
    );
    final now = FieldValue.serverTimestamp();
    try {
      await _db.runTransaction((tx) async {
        tx.set(pharmacy, {
          'ownerUid': uid,
          'name': name.trim(),
          'phone': phone.trim(),
          'address': address.trim(),
          'latitude': latitude,
          'longitude': longitude,
          'verificationStatus': 'pending',
          'deliveryAvailable': false,
          'codAvailable': false,
          'temporaryClosed': false,
          'timezone': 'Asia/Dhaka',
          'licenseLastFour': licenseNumber.trim().length >= 4
              ? licenseNumber.trim().substring(licenseNumber.trim().length - 4)
              : licenseNumber.trim(),
          'weeklyHours': {
            for (var day = 1; day <= 7; day++)
              '$day': {'open': false, 'from': '09:00', 'to': '21:00'},
          },
          'createdAt': now,
          'updatedAt': now,
        });
        tx.set(_db.collection('pharmacyUsers').doc(uid), {
          'uid': uid,
          'pharmacyId': pharmacy.id,
          'status': 'pending',
          'role': 'owner',
          'createdAt': now,
        });
        tx.set(pharmacy.collection('private').doc('verification'), {
          'licenseNumber': licenseNumber.trim(),
          'licenseFileName': licenseFileName,
          'licenseStoragePath': storagePath,
          'submittedAt': now,
        });
      });
    } catch (error) {
      try {
        await licenseRef.delete();
      } catch (_) {
        /* Ignore a failed cleanup. */
      }
      rethrow;
    }
    return pharmacy.id;
  }

  Future<List<Map<String, dynamic>>> incomingRequests() async {
    final pharmacy = await pharmacyForCurrentUser();
    if (pharmacy == null)
      throw const MedicineCommerceException(
        'Register a pharmacy profile first.',
      );
    final id = pharmacy['id'] as String;
    if (pharmacy['verificationStatus'] != 'verified' ||
        pharmacy['membershipStatus'] != 'verified') {
      throw const MedicineCommerceException(
        'Pharmacy verification is required before handling patient requests.',
      );
    }
    final snapshot = await _db
        .collection('pharmacyRequests')
        .where('pharmacyIds', arrayContains: id)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .where(
          (doc) => !{
            'cancelled',
            'expired',
            'rejected',
          }.contains(doc.data()['status']),
        )
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  Future<void> submitQuotation({
    required String requestId,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double deliveryFee,
    required String availability,
    required int? estimatedMinutes,
    required String notes,
    required bool prescriptionVerified,
    required bool containsAlternative,
    required bool deliveryAvailable,
  }) async {
    final pharmacy = await pharmacyForCurrentUser();
    if (pharmacy == null ||
        pharmacy['verificationStatus'] != 'verified' ||
        pharmacy['membershipStatus'] != 'verified') {
      throw const MedicineCommerceException(
        'Verified pharmacy access is required to submit a quotation.',
      );
    }
    if (subtotal < 0 ||
        deliveryFee < 0 ||
        (availability == 'available' && items.isEmpty)) {
      throw const MedicineCommerceException(
        'Enter valid prices and quote details.',
      );
    }
    if (containsAlternative && pharmacy['role'] != 'pharmacist') {
      throw const MedicineCommerceException(
        'Only a verified pharmacist can approve an alternative medicine.',
      );
    }
    final pharmacyId = pharmacy['id'] as String;
    final requestRef = _db.collection('pharmacyRequests').doc(requestId);
    final quoteRef = _db
        .collection('pharmacyQuotes')
        .doc('${requestId}_$pharmacyId');
    await _db.runTransaction((tx) async {
      final requestDoc = await tx.get(requestRef);
      if (!requestDoc.exists)
        throw const MedicineCommerceException('Request not found.');
      final request = requestDoc.data()!;
      final expires = _readDate(request['expiresAt']);
      if (!(request['pharmacyIds'] as List? ?? const []).contains(pharmacyId) ||
          request['cancelled'] == true ||
          (expires != null && expires.isBefore(DateTime.now()))) {
        throw const MedicineCommerceException(
          'This request is no longer available to your pharmacy.',
        );
      }
      final previousQuote = await tx.get(quoteRef);
      if (previousQuote.exists)
        throw const MedicineCommerceException(
          'Your pharmacy has already responded to this request.',
        );
      final status = requestDoc.data()?['status'];
      if (!{'pending', 'under_review', 'quoted'}.contains(status)) {
        throw const MedicineCommerceException(
          'This request is no longer accepting quotations.',
        );
      }
      if (request['type'] == 'prescription' &&
          prescriptionVerified &&
          pharmacy['role'] != 'pharmacist') {
        throw const MedicineCommerceException(
          'Prescription verification is reserved for an authorized pharmacist account.',
        );
      }
      final inventory = _db
          .collection('pharmacies')
          .doc(pharmacyId)
          .collection('inventory');
      final quoteItems = <Map<String, dynamic>>[];
      final checkedStockTimes = <DateTime>[];
      for (final source in items) {
        final item = Map<String, dynamic>.from(source);
        final name = (item['name'] as String? ?? '').trim();
        final strength = (item['strength'] as String? ?? '').trim();
        final formulation = (item['formulation'] as String? ?? '').trim();
        final stockId = _inventoryId(name, strength, formulation);
        item['inventoryItemId'] = stockId;
        final stockDoc = await tx.get(inventory.doc(stockId));
        final stock = stockDoc.data();
        if (stock == null || stock['active'] != true) {
          throw MedicineCommerceException(
            'Add $name $strength to pharmacy inventory before quoting it as available.',
          );
        }
        final lastChecked = _readDate(stock['lastStockConfirmedAt']);
        final stockQuantity = (stock['quantity'] as num?)?.toInt() ?? 0;
        final quoteQuantity = (item['quantity'] as num?)?.toInt() ?? 0;
        final stockPrice = (stock['unitPrice'] as num?)?.toDouble() ?? -1;
        final quotePrice = (item['unitPrice'] as num?)?.toDouble() ?? -2;
        if (lastChecked == null ||
            DateTime.now().toUtc().difference(lastChecked.toUtc()) >
                const Duration(minutes: 30) ||
            lastChecked.isAfter(
              DateTime.now().toUtc().add(const Duration(minutes: 2)),
            )) {
          throw MedicineCommerceException(
            'Refresh $name stock in inventory before sending a quotation.',
          );
        }
        if (quoteQuantity < 1 ||
            quoteQuantity > stockQuantity ||
            (quotePrice - stockPrice).abs() > 0.01) {
          throw MedicineCommerceException(
            'The quantity or price for $name differs from current inventory. Refresh it and try again.',
          );
        }
        item['total'] = quoteQuantity * quotePrice;
        quoteItems.add(item);
        checkedStockTimes.add(lastChecked.toUtc());
      }
      final checkedSubtotal = quoteItems.fold<double>(
        0,
        (sum, item) => sum + ((item['total'] as num?)?.toDouble() ?? 0),
      );
      if (quoteItems.isNotEmpty && (checkedSubtotal - subtotal).abs() > 0.01) {
        throw const MedicineCommerceException(
          'Quotation subtotal does not match the item prices.',
        );
      }
      checkedStockTimes.sort();
      tx.set(quoteRef, {
        'requestId': requestId,
        'requestType': request['type'],
        'patientUid': request['patientUid'],
        'pharmacyId': pharmacyId,
        'pharmacyName': pharmacy['name'],
        'distanceKm':
            request['latitude'] is num &&
                request['longitude'] is num &&
                pharmacy['latitude'] is num &&
                pharmacy['longitude'] is num
            ? distanceInKm(
                (request['latitude'] as num).toDouble(),
                (request['longitude'] as num).toDouble(),
                (pharmacy['latitude'] as num).toDouble(),
                (pharmacy['longitude'] as num).toDouble(),
              )
            : null,
        'items': quoteItems,
        'subtotal': quoteItems.isEmpty ? subtotal : checkedSubtotal,
        'deliveryFee': deliveryFee,
        'availability': availability,
        'estimatedMinutes': estimatedMinutes,
        'deliveryAvailable': deliveryAvailable,
        'stockConfirmedAt': checkedStockTimes.isEmpty
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(checkedStockTimes.first),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().toUtc().add(const Duration(minutes: 20)),
        ),
        'notes': notes.trim(),
        'requiresPrescriptionReview':
            request['type'] == 'prescription' && !prescriptionVerified,
        'prescriptionVerified':
            request['type'] == 'prescription' && prescriptionVerified,
        'containsAlternative': containsAlternative,
        'alternativeReviewed':
            containsAlternative && pharmacy['role'] == 'pharmacist',
        'reviewedByUid': prescriptionVerified || containsAlternative
            ? _uid
            : null,
        'status': 'submitted',
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(requestRef, {
        'status': 'quoted',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<String> confirmCodOrder({
    required PharmacyQuotation quote,
    required bool acceptAlternative,
  }) async {
    if (quote.containsAlternative && !acceptAlternative) {
      throw const MedicineCommerceException(
        'Review and explicitly accept the alternative before ordering.',
      );
    }
    if (quote.availability == AvailabilityStatus.outOfStock ||
        quote.availability == AvailabilityStatus.requiresReview) {
      throw const MedicineCommerceException(
        'This quotation is not ready to order.',
      );
    }
    if (quote.requestType == 'prescription' &&
        quote.requiresPrescriptionReview) {
      throw const MedicineCommerceException(
        'A pharmacist must verify the prescription before you can order.',
      );
    }
    final response = await _functions.httpsCallable('acceptPharmacyQuote').call(
      {'quoteId': quote.id, 'acceptAlternative': acceptAlternative},
    );
    final data = response.data;
    if (data is Map && data['orderId'] is String)
      return data['orderId'] as String;
    throw const MedicineCommerceException(
      'The order service returned an invalid response.',
    );
  }

  Future<List<Map<String, dynamic>>> listOrders() async {
    final snapshot = await _db
        .collection('medicineOrders')
        .where('patientUid', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<String> createMedicationPlan({
    required String name,
    required String strength,
    required double remainingQuantity,
    required double unitsPerDay,
    required String preferredPharmacyId,
    required bool prescriptionRequired,
    DateTime? prescriptionExpiresAt,
  }) async {
    if (name.trim().isEmpty ||
        remainingQuantity <= 0 ||
        unitsPerDay <= 0 ||
        preferredPharmacyId.isEmpty) {
      throw const MedicineCommerceException(
        'Enter a medicine, current supply, daily use, and preferred pharmacy.',
      );
    }
    final estimate = RefillEstimate.fromSupply(
      remainingQuantity: remainingQuantity,
      unitsPerDay: unitsPerDay,
      asOf: DateTime.now(),
    );
    if (estimate == null)
      throw const MedicineCommerceException('Supply details are invalid.');
    final doc = _db.collection('medicationPlans').doc();
    await doc.set({
      'patientUid': _uid,
      'name': name.trim(), 'strength': strength.trim(),
      'remainingQuantity': remainingQuantity, 'unitsPerDay': unitsPerDay,
      'preferredPharmacyId': preferredPharmacyId,
      'prescriptionRequired': prescriptionRequired,
      'prescriptionExpiresAt': prescriptionExpiresAt == null
          ? null
          : Timestamp.fromDate(prescriptionExpiresAt),
      // Patient-entered dates are retained for reference but cannot attest that
      // a prescription is current. Only a verified pharmacist review can do so.
      'prescriptionExpiryVerified': false,
      'estimatedRunOutAt': Timestamp.fromDate(estimate.estimatedRunOut),
      'remindAt': Timestamp.fromDate(estimate.remindAt),
      'reminderSentAt': null,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<List<Map<String, dynamic>>> listMedicationPlans() async {
    final snapshot = await _db
        .collection('medicationPlans')
        .where('patientUid', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> updateMedicationPlan(
    String id,
    Map<String, dynamic> updates,
  ) async {
    const allowed = {
      'active',
      'remindAt',
      'reminderSentAt',
      'snoozedAt',
      'updatedAt',
    };
    if (!allowed.containsAll(updates.keys))
      throw const MedicineCommerceException(
        'Unsupported medication plan update.',
      );
    await _db.collection('medicationPlans').doc(id).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> medicationReminderHistory(
    String planId,
  ) async {
    final snapshot = await _db
        .collection('medicationPlans')
        .doc(planId)
        .collection('reminderHistory')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> recordReminderSnooze(String planId) async {
    await _db
        .collection('medicationPlans')
        .doc(planId)
        .collection('reminderHistory')
        .add({'type': 'snoozed', 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<List<Map<String, dynamic>>> partnerOrders() async {
    final pharmacy = await pharmacyForCurrentUser();
    if (pharmacy == null || pharmacy['verificationStatus'] != 'verified')
      return [];
    final snapshot = await _db
        .collection('medicineOrders')
        .where('pharmacyId', isEqualTo: pharmacy['id'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> updateOrderStatus(
    String orderId,
    MedicineOrderStatus next,
  ) async {
    await _functions.httpsCallable('updateMedicineOrderStatus').call({
      'orderId': orderId,
      'status': next.name,
    });
  }

  Future<void> savePharmacySettings({
    required bool deliveryAvailable,
    required bool codAvailable,
    required bool temporaryClosed,
    required Map<int, PharmacyHours> weeklyHours,
    required Set<String> holidays,
    required Map<String, PharmacyHours> specialHours,
  }) async {
    final pharmacy = await pharmacyForCurrentUser();
    if (pharmacy == null)
      throw const MedicineCommerceException(
        'Register a pharmacy profile first.',
      );
    final weekly = {
      for (final entry in weeklyHours.entries)
        '${entry.key}': entry.value.toMap(),
    };
    final special = {
      for (final entry in specialHours.entries) entry.key: entry.value.toMap(),
    };
    await _db.collection('pharmacies').doc(pharmacy['id'] as String).update({
      'deliveryAvailable': deliveryAvailable,
      'codAvailable': codAvailable,
      'temporaryClosed': temporaryClosed,
      'weeklyHours': weekly,
      'holidays': holidays.toList(),
      'specialHours': special,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> inventory() async {
    final pharmacy = await pharmacyForCurrentUser();
    if (pharmacy == null) return [];
    final snapshot = await _db
        .collection('pharmacies')
        .doc(pharmacy['id'] as String)
        .collection('inventory')
        .orderBy('medicineNameNormalized')
        .limit(200)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> saveInventoryItem({
    String? id,
    required String name,
    required String strength,
    required String formulation,
    required int quantity,
    required double unitPrice,
  }) async {
    final pharmacy = await pharmacyForCurrentUser();
    if (pharmacy == null || pharmacy['verificationStatus'] != 'verified') {
      throw const MedicineCommerceException(
        'Verified pharmacy access is required to publish inventory.',
      );
    }
    if (name.trim().isEmpty || quantity < 0 || unitPrice < 0)
      throw const MedicineCommerceException('Enter valid inventory details.');
    final inventory = _db
        .collection('pharmacies')
        .doc(pharmacy['id'] as String)
        .collection('inventory');
    final newId = _inventoryId(name, strength, formulation);
    final ref = inventory.doc(newId);
    final batch = _db.batch();
    batch.set(ref, {
      'medicineName': name.trim(),
      'medicineNameNormalized': name.trim().toLowerCase(),
      'strength': strength.trim(),
      'formulation': formulation.trim(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lastStockConfirmedAt': FieldValue.serverTimestamp(),
      'active': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (id != null && id != newId) batch.delete(inventory.doc(id));
    await batch.commit();
  }

  Future<String> uploadPharmacyLogo({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final pharmacy = await pharmacyForCurrentUser();
    if (pharmacy == null ||
        pharmacy['verificationStatus'] != 'verified' ||
        pharmacy['membershipStatus'] != 'verified') {
      throw const MedicineCommerceException(
        'Only a verified pharmacy can publish its logo.',
      );
    }
    if (bytes.isEmpty ||
        bytes.length > 5 * 1024 * 1024 ||
        !{'image/jpeg', 'image/png'}.contains(mimeType) ||
        !_matchesFileSignature(bytes, mimeType)) {
      throw const MedicineCommerceException(
        'Use a valid JPG or PNG logo smaller than 5 MB.',
      );
    }
    final reference = _storage.ref(
      'pharmacy-logos/${pharmacy['id'] as String}/logo',
    );
    await reference.putData(bytes, SettableMetadata(contentType: mimeType));
    final downloadUrl = await reference.getDownloadURL();
    await _db.collection('pharmacies').doc(pharmacy['id'] as String).update({
      'logoUrl': downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return downloadUrl;
  }

  void _validatePharmacySelection(List<String> ids) {
    if (ids.isEmpty || ids.length > 4 || ids.toSet().length != ids.length) {
      throw const MedicineCommerceException(
        'Select 1 to 4 different nearby pharmacies.',
      );
    }
  }

  DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _inventoryId(
    String name,
    String strength,
    String formulation,
  ) => base64Url
      .encode(
        utf8.encode(
          '${name.trim().toLowerCase()}|${strength.trim().toLowerCase()}|${formulation.trim().toLowerCase()}',
        ),
      )
      .replaceAll('=', '');

  bool _matchesFileSignature(Uint8List bytes, String mimeType) {
    if (mimeType == 'image/jpeg') {
      return bytes.length >= 3 &&
          bytes[0] == 0xff &&
          bytes[1] == 0xd8 &&
          bytes[2] == 0xff;
    }
    if (mimeType == 'image/png') {
      const signature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
      return bytes.length >= signature.length &&
          signature.asMap().entries.every(
            (entry) => bytes[entry.key] == entry.value,
          );
    }
    if (mimeType == 'application/pdf') {
      return bytes.length >= 5 &&
          String.fromCharCodes(bytes.sublist(0, 5)) == '%PDF-';
    }
    return false;
  }
}
