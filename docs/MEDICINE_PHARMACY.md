# Medicine & Pharmacy Integration

This module extends the existing Flutter application. It uses Firebase Authentication, Cloud Firestore, Cloud Storage, callable Cloud Functions, and Firebase Cloud Messaging. It does not introduce a separate app or a REST server.

## Architecture

`PharmacyRepository` is the app's data boundary. Nearby search uses indexed latitude and longitude bounds, then computes exact Haversine distance for the bounded result set. Pharmacy hours use `Asia/Dhaka`, weekday schedules, holiday overrides, special-date hours, overnight schedules, and temporary closures.

The client creates patient requests, uploads private prescription files, manages pharmacist inventory, and submits quotations. Firestore rules limit each operation to the patient or verified pharmacy involved. Two operations with inventory or order consequences run in Cloud Functions using Admin SDK transactions:

- `acceptPharmacyQuote({ quoteId, acceptAlternative })` checks request and quote expiry, verified pharmacy and pharmacist membership, explicit alternative acceptance, COD/delivery support, the current inventory price and quantity, and the stock-confirmation age. It decrements stock and creates the order atomically. Repeating the call returns the existing order.
- `updateMedicineOrderStatus({ orderId, status })` validates allowed transitions and limits partner updates to the verified pharmacy on the order. Patients may cancel a confirmed or processing order.

Both callable functions run in `asia-south1`. Firestore triggers create in-app notifications and send FCM notifications. The scheduled reminder function runs every 15 minutes in Bangladesh time. Notification failures are caught after business writes and cannot roll back an order.

## Collections and access

| Collection | Purpose | Access summary |
|---|---|---|
| `pharmacies/{pharmacyId}` | Public verified listing, coordinates, services, hours, logo | Verified listings are readable to signed-in users; verification fields are admin-controlled |
| `pharmacies/{id}/private/verification` | License number and private license path | Pharmacy owner and admin only |
| `pharmacies/{id}/inventory/{itemId}` | Quantity, price, stock confirmation timestamp | Active entries are readable to signed-in users; verified pharmacy members manage them |
| `pharmacyUsers/{uid}` | Pharmacy membership and role | Own user or admin; verification is admin-controlled |
| `pharmacyRequests/{requestId}` | Availability or prescription request | Patient and the verified selected pharmacies |
| `prescriptions/{prescriptionId}` | Prescription metadata and source path | Patient and pharmacies with an active share |
| `prescriptionShares/{patientUid}_{prescriptionId}_{pharmacyId}` | Time-limited pharmacy access grant | Patient can create/revoke; only selected verified pharmacy can use an active grant |
| `pharmacyQuotes/{requestId}_{pharmacyId}` | One quotation per pharmacy per request | Patient and the quoting pharmacy; clients cannot change quote status |
| `medicineOrders/{quoteId}` | Confirmed order and status history | Patient and pharmacy on the order; create/status transitions use Functions |
| `medicationPlans/{planId}` | User-entered supply and reminder estimate | Patient only |
| `medicationPlans/{planId}/reminderHistory/{eventId}` | Reminder sent/snoozed history | Patient reads; patient snooze entries are client-created |
| `notifications/{notificationId}` | In-app notification | Recipient reads; Cloud Functions write |
| `userDevices/{uid}/tokens/{tokenId}` | FCM registration token | Owner only |

The Firestore and Storage rules are in `firestore.rules` and `storage.rules`; composite indexes are in `firestore.indexes.json`. Cloud Functions use the Admin SDK, so the server-side transaction code is the trust boundary for stock decrement and order creation.

## Local setup

1. Install Flutter/Dart and Node.js 22. Run `flutter pub get` in the project root and `npm ci` in `functions/`.
2. Configure the existing Firebase project with FlutterFire CLI (`flutterfire configure`) and verify `lib/firebase_options.dart`, Android `google-services.json`, and iOS `GoogleService-Info.plist` are for the intended project. Never commit service-account keys.
3. Enable Firebase Authentication providers used by the app, Cloud Firestore, Cloud Storage, Cloud Functions, and Firebase Cloud Messaging. Scheduled Functions and deployment of Functions require a billing-enabled Firebase project. Configure APNs credentials and the iOS push-notification capability for iOS delivery.
4. Deploy the database rules, indexes, Storage rules, and Functions from the repository root. The Firebase CLI does not use the FlutterFire project ID as its default, so pass the intended project explicitly:

   ```sh
   firebase deploy --project aafiyah-433dc --only firestore:rules,firestore:indexes,storage,functions
   ```

5. The app uses `asia-south1` for callable Functions. Deploy there and confirm the Functions are available before testing order confirmation. Configure required Firebase app IDs and platform files; there are no additional API keys in this module.
6. For iOS, install CocoaPods dependencies with `cd ios && pod install`. The Google ML Kit text recognition plugin requires the iOS deployment target to remain at 15.5 or later. Android camera/location/notification permissions are declared in the existing manifest.
7. Initialize time zones in app startup or allow the module to initialize the bundled `Asia/Dhaka` database on first use. OpenStreetMap tiles are used by the map and attribution is displayed; production deployments with significant traffic should configure a tile provider with an appropriate service agreement.

## Pharmacy verification and roles

Registration creates a pending pharmacy, a pending owner membership, and private license metadata. Pending accounts cannot see patient requests or manage inventory. A trusted operator must review the license and business details and, using a privileged Admin SDK workflow, set `pharmacies/{pharmacyId}.verificationStatus` and `pharmacyUsers/{uid}.status` to `verified`. Set membership `role` to `owner` or `pharmacist`; only a pharmacist membership can attest prescription review or alternative review. The client cannot grant these roles. No self-service admin console is included in this repository.

For trusted operator setup, first grant the Firebase Auth custom claim `admin: true` from a secure Admin SDK environment. Preserve any existing claims when setting it; never expose an Admin SDK credential in the app. After checking a registration and its private license document, set the pharmacy document to `verificationStatus: 'verified'` and add review metadata such as `verificationReviewedAt`/`verificationReviewedByUid`; update the owner's `pharmacyUsers/{uid}` membership to `status: 'verified'` and `role: 'owner'`. For a pharmacist, create or update that user's membership with the same `pharmacyId`, `status: 'verified'`, `role: 'pharmacist'`, and `uid`. Force a fresh Auth token after changing custom claims. These actions use Admin SDK privileges and bypass client rules.

## Prescription and clinical safety

Prescription files are uploaded to private Storage paths with a maximum size of 10 MiB. The app checks file extension, declared type, and common file signatures before upload; Storage rules also restrict content type and size. The original file is retained when an edited crop is submitted. Pharmacists view the source using authenticated Storage reads; the app does not create a long-lived public prescription URL. Prescription sharing expires after seven days and can be revoked when a request is cancelled.

On-device OCR is available on Android/iOS for image files. It displays raw extracted text as unverified and does not infer or change dosage. PDF files can be previewed, but OCR extraction from PDF pages is not implemented. Prescriber and prescription dates are patient-entered metadata. The original is the source of truth, and a verified pharmacist must attest prescription review before fulfillment.

Refill estimates use the user's recorded remaining quantity and daily use, and schedule a reminder about two days before the estimated run-out. Reminders never create orders automatically. Prescription expiry is treated as unverified in a medication plan; the patient must submit current documentation when required. The current workflow does not link a pharmacist-verified prescription expiry back to a refill plan, so prescription-required refills will request new documentation.

## Validation and operational boundaries

- Nearby results and request/order history are bounded to 50 records; inventory is bounded. The app does not expose cursor-based pagination yet.
- Firestore rules and Cloud Functions enforce identity, pharmacy verification, order transitions, and transaction consistency. There is no per-user rate limiter; Function instance limits are capacity controls, not abuse throttling.
- Client-side prescription signature checks supplement Storage content-type and size rules. A server-side malware scan and authoritative file-signature verification are not configured.
- Detailed prescription-view audit events and a privileged verification console are not implemented. Order status history is stored on each order.
- FCM and local refill reminders are both wired. Configure notification preferences and test foreground/background delivery on actual devices before rollout.
- Only cash-on-delivery orders are supported. Online payment, courier integration, pharmacy dispute/refund flows, medicine catalog search, and automatic refill fulfillment are outside this implementation.
- Firestore is the new commerce store; no SQL migrations apply. Existing Isar medication data remains untouched and is not automatically imported into refill plans.
- Obtain qualified Bangladesh legal, pharmacy-licensing, privacy, and consumer-protection review before operating with real patients. Software controls do not establish regulatory compliance.

## Tests

Run `flutter test` for the Flutter suite, and `npm test` plus `npm run lint` in `functions/` for the backend domain tests and syntax check. Firebase Emulator Suite tests for Firestore/Storage rules and callable transactions are not included; deploy to a non-production Firebase project and verify authorization and transaction behavior before launch.
