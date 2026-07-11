import 'package:flutter_test/flutter_test.dart';
import 'package:aafiyah/features/pharmacy/domain/pharmacy_models.dart';

void main() {
  group('Pharmacy hours in Asia/Dhaka', () {
    Pharmacy pharmacy({
      Map<int, PharmacyHours>? hours,
      Set<String> holidays = const {},
      Map<String, PharmacyHours> special = const {},
      bool closed = false,
    }) => Pharmacy(
      id: 'p1',
      name: 'Test Pharmacy',
      address: 'Dhaka',
      phone: '000',
      latitude: 23.8,
      longitude: 90.4,
      verification: PharmacyVerification.verified,
      deliveryAvailable: true,
      codAvailable: true,
      weeklyHours: hours ?? const {},
      holidays: holidays,
      specialHours: special,
      temporaryClosed: closed,
    );

    test('uses Bangladesh local weekday and opening time', () {
      final value = pharmacy(
        hours: {
          DateTime.monday: const PharmacyHours(
            open: true,
            from: '09:00',
            to: '17:00',
          ),
        },
      );
      expect(value.isOpenAt(DateTime.utc(2026, 11, 2, 2, 59)), isFalse);
      expect(value.isOpenAt(DateTime.utc(2026, 11, 2, 3)), isTrue);
      expect(value.isOpenAt(DateTime.utc(2026, 11, 2, 11)), isFalse);
    });

    test('keeps overnight opening hours active after midnight', () {
      final value = pharmacy(
        hours: {
          DateTime.sunday: const PharmacyHours(
            open: true,
            from: '19:00',
            to: '02:00',
          ),
        },
      );
      expect(value.isOpenAt(DateTime.utc(2026, 11, 1, 19, 59)), isTrue);
      expect(value.isOpenAt(DateTime.utc(2026, 11, 1, 20)), isFalse);
    });

    test(
      'holiday, special hours, and temporary closure override weekly hours',
      () {
        final regular = {
          DateTime.monday: const PharmacyHours(
            open: true,
            from: '09:00',
            to: '17:00',
          ),
        };
        final instant = DateTime.utc(2026, 11, 2, 4); // 10:00 in Dhaka.
        expect(
          pharmacy(hours: regular, holidays: {'2026-11-02'}).isOpenAt(instant),
          isFalse,
        );
        expect(
          pharmacy(
            hours: regular,
            special: {
              '2026-11-02': const PharmacyHours(
                open: true,
                from: '10:30',
                to: '11:00',
              ),
            },
          ).isOpenAt(instant),
          isFalse,
        );
        expect(
          pharmacy(hours: regular, closed: true).isOpenAt(instant),
          isFalse,
        );
      },
    );
  });

  test('great-circle distance returns kilometers', () {
    expect(distanceInKm(0, 0, 0, 1), closeTo(111.195, 0.1));
    expect(distanceInKm(23.8103, 90.4125, 23.8103, 90.4125), 0);
  });

  test('availability request expiry and cancellation are terminal', () {
    final expired = MedicineAvailabilityRequest(
      id: 'expired',
      patientUid: 'patient',
      medicineName: 'Medicine A',
      strength: '10 mg',
      formulation: 'Tablet',
      quantity: 2,
      pharmacyIds: const ['pharmacy'],
      expiresAt: DateTime(2000),
      cancelled: false,
    );
    final cancelled = MedicineAvailabilityRequest(
      id: 'cancelled',
      patientUid: 'patient',
      medicineName: 'Medicine A',
      strength: '10 mg',
      formulation: 'Tablet',
      quantity: 2,
      pharmacyIds: const ['pharmacy'],
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      cancelled: true,
    );
    expect(expired.isExpired, isTrue);
    expect(cancelled.isExpired, isTrue);
  });

  test('order state machine allows only declared forward transitions', () {
    expect(
      MedicineOrderStateMachine.canTransition(
        MedicineOrderStatus.confirmed,
        MedicineOrderStatus.processing,
      ),
      isTrue,
    );
    expect(
      MedicineOrderStateMachine.canTransition(
        MedicineOrderStatus.delivered,
        MedicineOrderStatus.processing,
      ),
      isFalse,
    );
    expect(
      MedicineOrderStateMachine.canTransition(
        MedicineOrderStatus.pending,
        MedicineOrderStatus.dispatched,
      ),
      isFalse,
    );
  });

  test(
    'refill estimate reminds about two days before recorded supply ends',
    () {
      final asOf = DateTime.utc(2026, 11, 1);
      final estimate = RefillEstimate.fromSupply(
        remainingQuantity: 20,
        unitsPerDay: 2,
        asOf: asOf,
      )!;
      expect(estimate.estimatedRunOut, DateTime.utc(2026, 11, 11));
      expect(estimate.remindAt, DateTime.utc(2026, 11, 9));
      expect(
        RefillEstimate.fromSupply(
          remainingQuantity: 1,
          unitsPerDay: 0,
          asOf: asOf,
        ),
        isNull,
      );
    },
  );
}
