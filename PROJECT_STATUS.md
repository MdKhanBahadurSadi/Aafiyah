# Aafiyah project status

## Medicine ordering and pharmacy integration

**Implementation status: feature code and documentation are in place; production rollout remains dependent on Firebase project setup, trusted pharmacy verification, and emulator/device validation.** This module is integrated into the existing Flutter app and Firebase architecture. Existing Isar medication data and unrelated user edits were preserved.

### Phase 1 — codebase analysis and architecture

- Confirmed Flutter with Provider, Firebase Authentication/Firestore, existing prescription and medication reminder features, local Isar storage, notification infrastructure, route registration, and Aafiyah styling.
- Kept the commerce domain in a new pharmacy feature module. Firestore and Storage are the online data stores; local medication storage was not replaced.
- Architecture and collection access are documented in [docs/MEDICINE_PHARMACY.md](docs/MEDICINE_PHARMACY.md).

### Phase 2 — backend and data foundation

- Added Firestore collections and indexes, Firestore/Storage rules, and Node 22 Firebase Functions.
- Callable order acceptance uses a Firestore transaction to recheck verified membership, quote/request expiry, pharmacist review, COD/delivery support, exact inventory items and prices, and fresh stock; it decrements quantity and creates one idempotent order.
- Added the order status callable, request/quote/order notifications, device token registration, and a scheduled medication reminder function.
- No schema migration is required for the existing Isar data. Commerce rules and callables have not been deployed to the Firebase project.

### Phase 3 — pharmacy verification and discovery

- Added pending pharmacy registration with private license upload and map-selected coordinates. A trusted admin must verify the pharmacy and its owner membership before commerce access.
- Added bounded latitude/longitude discovery, exact distance sorting, 2–5 km radius controls, delivery filter, map/list switch, map markers, pharmacy details, call/directions actions, logos, and Bangladesh-time operating hours with holidays/special hours/overnight handling.
- Search results and inventory are capped; cursor pagination is not implemented.

### Phase 4 — prescription workflow

- Added camera/file upload for JPG/JPEG/PNG/PDF, image crop, PDF preview, metadata capture, and on-device image OCR on Android/iOS. Original image bytes remain the source of truth; OCR is labeled unverified and not used for clinical decisions.
- Patients select up to four pharmacies. Prescription Storage reads are authenticated and limited to the patient or a selected verified pharmacy with an active seven-day share; cancellation revokes access.
- Pharmacy request review and quotation screens require a verified pharmacist membership to attest prescription review before the order service will fulfill. Patient-entered prescriber/date details remain unverified.
- PDF OCR, server-side malware/file-signature scanning, and prescription-view audit events are not implemented.

### Phase 5 — availability and quotations

- Added one-to-four pharmacy availability requests, expiring requests, cancellation, deduplicated per-pharmacy quote IDs, pharmacy response entry, fresh-stock checks, and patient response streams.
- Added a side-by-side comparison of availability, quantity, price, distance, delivery, ETA, and stock-check time in Bangladesh time.
- Alternatives require pharmacist review and explicit patient acceptance. The server rejects stale stock and changed prices at confirmation.

### Phase 6 — medication supply and refills

- Added user-entered supply plans, run-out estimates, two-day reminders, local and push reminder plumbing, snooze, pause/resume, reminder history, and preferred-pharmacy availability requests.
- No reminder places an order automatically. Prescription-required plans currently remain unverified and request current prescription documentation; there is no workflow to link a pharmacist-verified expiry back to a plan.

### Phase 7 — notifications

- Added FCM device-token lifecycle handling and server-generated in-app/push notifications for requests, quotations, orders, and scheduled refill reminders. Notification failures do not roll back commerce writes.
- APNs, Android production messaging, and local/push behavior need end-to-end validation on configured devices. Users can receive both local and push refill reminders until notification preferences/deduplication are added.

### Phase 8 — integration and quality checks

- Added the Medicine & Pharmacy route and home-screen entry without replacing existing app modules.
- `flutter test`: **12 passed**.
- `npm test` in `functions/`: **3 passed**. `npm run lint`: **passed** (Node syntax check).
- Targeted `dart analyze`: **no errors or warnings; 52 info-level style notices**.
- Firebase and Firestore index JSON parsing: **passed**.
- Firestore Emulator validation was attempted but could not start: the local Java emulator process exited while opening a loopback selector (`Unable to establish loopback connection`). Rules behavior has not been emulator-tested.
- `npm audit --omit=dev` reports **6 moderate transitive dependency findings** in glob/minimatch-related dependencies; `npm audit fix` could not resolve them within current dependency constraints.

### Phase 9 — setup and limitations

- Added deployment, data access, pharmacy verification, safety, platform setup, and testing instructions in [docs/MEDICINE_PHARMACY.md](docs/MEDICINE_PHARMACY.md).
- Firebase has not been deployed or exercised against live credentials. A trusted operator must configure custom admin claims and verify pharmacy and pharmacist memberships.
- Only COD is implemented. Online payments, courier integration, per-user rate limiting, cursor pagination, a privileged admin console, and legal/regulatory approval are pending external/product work.

### Primary implementation files

- `lib/features/pharmacy/domain/pharmacy_models.dart`
- `lib/features/pharmacy/data/pharmacy_repository.dart`
- `lib/features/pharmacy/presentation/pages/medicine_pharmacy_home_page.dart`
- `lib/features/pharmacy/presentation/pages/pharmacy_partner_page.dart`
- `lib/features/pharmacy/presentation/pages/refills_tab.dart`
- `functions/index.js`, `functions/domain.js`
- `firestore.rules`, `storage.rules`, `firestore.indexes.json`
