const admin = require('firebase-admin');
const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {onDocumentCreated, onDocumentUpdated} = require('firebase-functions/v2/firestore');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const {allowedTransitions, finiteNonNegative, inventoryKey, orderSubtotal} = require('./domain');

admin.initializeApp();

const db = admin.firestore();
const {FieldValue, Timestamp} = admin.firestore;
const REGION = 'asia-south1';
const MAX_STOCK_AGE_MS = 30 * 60 * 1000;

function requireUid(request) {
  if (!request.auth?.uid) throw new HttpsError('unauthenticated', 'Sign in to continue.');
  return request.auth.uid;
}

function fail(message, code = 'failed-precondition') {
  throw new HttpsError(code, message);
}

function timestampMillis(value) {
  return value && typeof value.toMillis === 'function' ? value.toMillis() : NaN;
}

exports.acceptPharmacyQuote = onCall({region: REGION, maxInstances: 10, timeoutSeconds: 30}, async (request) => {
  const uid = requireUid(request);
  const quoteId = request.data?.quoteId;
  const acceptAlternative = request.data?.acceptAlternative === true;
  if (typeof quoteId !== 'string' || quoteId.length < 4 || quoteId.length > 400) {
    fail('Quotation is invalid.', 'invalid-argument');
  }

  const quoteRef = db.collection('pharmacyQuotes').doc(quoteId);
  const orderRef = db.collection('medicineOrders').doc(quoteId);
  const result = await db.runTransaction(async (transaction) => {
    const [quoteSnapshot, orderSnapshot] = await Promise.all([
      transaction.get(quoteRef), transaction.get(orderRef),
    ]);
    if (orderSnapshot.exists) {
      if (orderSnapshot.data().patientUid !== uid) fail('Quotation is not available.');
      return {orderId: orderRef.id, alreadyConfirmed: true};
    }
    if (!quoteSnapshot.exists) fail('Quotation was not found.', 'not-found');
    const quote = quoteSnapshot.data();
    if (quote.patientUid !== uid || quote.status !== 'submitted') fail('Quotation is no longer available.');
    if (timestampMillis(quote.expiresAt) <= Date.now()) fail('Quotation has expired.');
    if (!['available', 'partial'].includes(quote.availability)) fail('This quotation is not ready to order.');
    if (quote.containsAlternative === true && (!acceptAlternative || quote.alternativeReviewed !== true)) {
      fail('A verified pharmacist must review the alternative, and you must accept it explicitly.');
    }
    if (quote.requestType === 'prescription' && (quote.prescriptionVerified !== true || quote.requiresPrescriptionReview === true)) {
      fail('A verified pharmacist must review the original prescription before fulfillment.');
    }

    const requestRef = db.collection('pharmacyRequests').doc(quote.requestId);
    const pharmacyRef = db.collection('pharmacies').doc(quote.pharmacyId);
    const requestSnapshot = await transaction.get(requestRef);
    const pharmacySnapshot = await transaction.get(pharmacyRef);
    if (!requestSnapshot.exists || !pharmacySnapshot.exists) fail('The pharmacy request is no longer available.');
    const pharmacyRequest = requestSnapshot.data();
    const pharmacy = pharmacySnapshot.data();
    if (pharmacyRequest.patientUid !== uid || pharmacyRequest.status !== 'quoted' || pharmacyRequest.cancelled === true) {
      fail('The pharmacy request is no longer active.');
    }
    if (timestampMillis(pharmacyRequest.expiresAt) <= Date.now()) fail('The pharmacy request has expired.');
    if (!(pharmacyRequest.pharmacyIds || []).includes(quote.pharmacyId)) fail('This pharmacy was not selected for the request.');
    if (pharmacy.verificationStatus !== 'verified' || pharmacy.codAvailable !== true || pharmacy.deliveryAvailable !== true || quote.deliveryAvailable !== true) {
      fail('This verified pharmacy cannot currently deliver a cash-on-delivery order.');
    }

    if (quote.requestType === 'prescription' || quote.containsAlternative === true) {
      const reviewerUid = quote.reviewedByUid;
      if (typeof reviewerUid !== 'string') fail('A verified pharmacist review is required.');
      const reviewerRef = db.collection('pharmacyUsers').doc(reviewerUid);
      const reviewerSnapshot = await transaction.get(reviewerRef);
      const reviewer = reviewerSnapshot.data();
      if (!reviewerSnapshot.exists || reviewer.status !== 'verified' || reviewer.role !== 'pharmacist' || reviewer.pharmacyId !== quote.pharmacyId) {
        fail('Only a verified pharmacist at this pharmacy can approve prescription details or alternatives.');
      }
    }

    if (!Array.isArray(quote.items) || quote.items.length === 0 || quote.items.length > 25) fail('Quotation item list is invalid.');
    const inventoryRefs = [];
    const itemQuantities = new Map();
    let computedSubtotal = 0;
    for (const item of quote.items) {
      if (!item || typeof item.name !== 'string' || !Number.isInteger(item.quantity) || item.quantity < 1 || !finiteNonNegative(item.unitPrice)) {
        fail('Quotation contains invalid medicine or price details.');
      }
      const key = inventoryKey(item.name, item.strength, item.formulation);
      if (item.inventoryItemId !== key || itemQuantities.has(key)) fail('Quotation stock references are invalid.');
      itemQuantities.set(key, item.quantity);
      inventoryRefs.push(db.collection('pharmacies').doc(quote.pharmacyId).collection('inventory').doc(key));
      computedSubtotal += item.quantity * item.unitPrice;
    }
    if (!finiteNonNegative(quote.subtotal) || Math.abs(computedSubtotal - quote.subtotal) > 0.01 || !finiteNonNegative(quote.deliveryFee)) {
      fail('Quotation total does not match its medicine line items.');
    }
    if (quote.requestType === 'availability') {
      const requested = Number(pharmacyRequest.quantity);
      const quoted = quote.items.reduce((sum, item) => sum + item.quantity, 0);
      if (quote.availability === 'available' && quoted < requested) fail('Mark this response as partial when stock is below the requested quantity.');
      if (quote.availability === 'partial' && quoted >= requested) fail('The requested quantity is available; refresh the quotation status.');
    }

    const inventorySnapshots = [];
    for (const reference of inventoryRefs) inventorySnapshots.push(await transaction.get(reference));
    const nowMillis = Date.now();
    for (let index = 0; index < inventorySnapshots.length; index++) {
      const snapshot = inventorySnapshots[index];
      const item = quote.items[index];
      const inventory = snapshot.data();
      if (!snapshot.exists || inventory.active !== true) fail(`The pharmacy no longer lists ${item.name} in active inventory.`);
      const stockAge = nowMillis - timestampMillis(inventory.lastStockConfirmedAt);
      if (!Number.isFinite(stockAge) || stockAge < -120000 || stockAge > MAX_STOCK_AGE_MS) {
        fail(`The stock confirmation for ${item.name} is stale. Request a refreshed quotation.`);
      }
      if (inventory.quantity < item.quantity || Math.abs(inventory.unitPrice - item.unitPrice) > 0.01) {
        fail(`The price or quantity for ${item.name} changed. Request a refreshed quotation.`);
      }
      if (String(inventory.medicineName || '').trim().toLowerCase() !== String(item.name).trim().toLowerCase() ||
          String(inventory.strength || '').trim().toLowerCase() !== String(item.strength || '').trim().toLowerCase() ||
          String(inventory.formulation || '').trim().toLowerCase() !== String(item.formulation || '').trim().toLowerCase()) {
        fail('A quotation medicine does not match the pharmacy inventory entry.');
      }
    }

    const serverNow = Timestamp.now();
    transaction.update(quoteRef, {status: 'accepted', acceptedAt: FieldValue.serverTimestamp()});
    transaction.update(requestRef, {
      status: 'accepted', selectedQuoteId: quoteId, updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.set(orderRef, {
      patientUid: uid,
      pharmacyId: quote.pharmacyId,
      pharmacyName: quote.pharmacyName,
      quoteId,
      requestId: quote.requestId,
      requestType: quote.requestType,
      items: quote.items,
      subtotal: quote.subtotal,
      deliveryFee: quote.deliveryFee,
      total: computedSubtotal + quote.deliveryFee,
      deliveryAddress: pharmacyRequest.deliveryAddress || null,
      contactNumber: pharmacyRequest.contactNumber || null,
      paymentMethod: 'cod',
      status: 'confirmed',
      prescriptionVerified: quote.prescriptionVerified === true,
      acceptedAlternative: quote.containsAlternative === true && acceptAlternative,
      statusHistory: [
        {status: 'accepted', at: serverNow},
        {status: 'codSelected', at: serverNow},
        {status: 'confirmed', at: serverNow},
      ],
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    for (let index = 0; index < inventorySnapshots.length; index++) {
      const reference = inventoryRefs[index];
      const inventory = inventorySnapshots[index].data();
      transaction.update(reference, {
        quantity: inventory.quantity - quote.items[index].quantity,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    return {orderId: orderRef.id, alreadyConfirmed: false};
  });
  return result;
});

exports.updateMedicineOrderStatus = onCall({region: REGION, maxInstances: 10}, async (request) => {
  const uid = requireUid(request);
  const {orderId, status: nextStatus} = request.data || {};
  if (typeof orderId !== 'string' || typeof nextStatus !== 'string') fail('Order update is invalid.', 'invalid-argument');
  const orderRef = db.collection('medicineOrders').doc(orderId);
  await db.runTransaction(async (transaction) => {
    const orderSnapshot = await transaction.get(orderRef);
    if (!orderSnapshot.exists) fail('Order was not found.', 'not-found');
    const order = orderSnapshot.data();
    const patientCancel = nextStatus === 'cancelled' && order.patientUid === uid && ['confirmed', 'processing'].includes(order.status);
    if (!patientCancel) {
      if (!allowedTransitions[order.status]?.has(nextStatus)) fail('That order status transition is not allowed.');
      const membershipRef = db.collection('pharmacyUsers').doc(uid);
      const membershipSnapshot = await transaction.get(membershipRef);
      const membership = membershipSnapshot.data();
      if (!membershipSnapshot.exists || membership.status !== 'verified' || membership.pharmacyId !== order.pharmacyId) {
        fail('Only a verified pharmacy handling this order can update its status.');
      }
      const pharmacySnapshot = await transaction.get(db.collection('pharmacies').doc(order.pharmacyId));
      if (!pharmacySnapshot.exists || pharmacySnapshot.data().verificationStatus !== 'verified') fail('Pharmacy verification is required.');
    }
    if (patientCancel && !allowedTransitions[order.status]?.has('cancelled')) fail('This order can no longer be cancelled.');
    if (order.status === nextStatus) return;
    transaction.update(orderRef, {
      status: nextStatus,
      updatedAt: FieldValue.serverTimestamp(),
      statusHistory: FieldValue.arrayUnion({status: nextStatus, at: Timestamp.now(), by: uid}),
    });
  });
  return {orderId, status: nextStatus};
});

async function createNotification(userUid, {type, title, body, relatedId}) {
  try {
    await db.collection('notifications').add({
      userUid, type, title, body, relatedId: relatedId || null,
      read: false, createdAt: FieldValue.serverTimestamp(),
    });
    const tokensSnapshot = await db.collection('userDevices').doc(userUid).collection('tokens').limit(500).get();
    const tokens = tokensSnapshot.docs.map((document) => ({id: document.id, token: document.data().token})).filter((entry) => typeof entry.token === 'string');
    for (let offset = 0; offset < tokens.length; offset += 500) {
      const batch = tokens.slice(offset, offset + 500);
      const response = await admin.messaging().sendEachForMulticast({
        tokens: batch.map((entry) => entry.token),
        notification: {title, body},
        data: {type, relatedId: relatedId || ''},
      });
      const deletes = [];
      response.responses.forEach((result, index) => {
        if (!result.success && ['messaging/invalid-registration-token', 'messaging/registration-token-not-registered'].includes(result.error?.code)) {
          deletes.push(tokensSnapshot.ref.doc(batch[index].id).delete());
        }
      });
      await Promise.allSettled(deletes);
    }
  } catch (error) {
    // Notification delivery runs after the business write and never rolls it back.
    console.error('Notification delivery failed', {type, userUid, error: String(error)});
  }
}

exports.notifyPharmacyRequest = onDocumentCreated({document: 'pharmacyRequests/{requestId}', region: REGION}, async (event) => {
  const request = event.data?.data();
  if (!request) return;
  const pharmacyIds = (request.pharmacyIds || []).slice(0, 4);
  for (const pharmacyId of pharmacyIds) {
    const memberships = await db.collection('pharmacyUsers').where('pharmacyId', '==', pharmacyId).where('status', '==', 'verified').limit(10).get();
    const label = request.type === 'prescription' ? 'Prescription request' : 'Medicine availability request';
    await Promise.all(memberships.docs.map((membership) => createNotification(membership.id, {
      type: 'pharmacy_request', title: label, body: 'A patient sent a request to your pharmacy.', relatedId: event.params.requestId,
    })));
  }
});

exports.notifyNewQuotation = onDocumentCreated({document: 'pharmacyQuotes/{quoteId}', region: REGION}, async (event) => {
  const quote = event.data?.data();
  if (!quote || !quote.patientUid) return;
  await createNotification(quote.patientUid, {
    type: 'quotation', title: 'Pharmacy quotation received', body: `${quote.pharmacyName || 'A pharmacy'} replied to your request.`, relatedId: event.params.quoteId,
  });
});

exports.notifyOrderStatus = onDocumentUpdated({document: 'medicineOrders/{orderId}', region: REGION}, async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after || before.status === after.status) return;
  const message = `Your order status is now ${after.status}.`;
  await createNotification(after.patientUid, {type: 'order_status', title: 'Medicine order update', body: message, relatedId: event.params.orderId});
  const pharmacy = await db.collection('pharmacies').doc(after.pharmacyId).get();
  const ownerUid = pharmacy.data()?.ownerUid;
  if (ownerUid && ownerUid !== after.patientUid) {
    await createNotification(ownerUid, {type: 'order_status', title: 'Order status updated', body: `Order ${event.params.orderId.slice(0, 8)} is now ${after.status}.`, relatedId: event.params.orderId});
  }
});

exports.sendMedicationRefillReminders = onSchedule({schedule: 'every 15 minutes', region: REGION, timeZone: 'Asia/Dhaka', maxInstances: 1}, async () => {
  const due = await db.collection('medicationPlans').where('active', '==', true)
    .where('reminderSentAt', '==', null).where('remindAt', '<=', Timestamp.now()).limit(250).get();
  await Promise.all(due.docs.map(async (document) => {
    let shouldSend = false;
    const historyRef = document.ref.collection('reminderHistory').doc();
    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(document.ref);
      const plan = snapshot.data();
      if (!plan || plan.active !== true || plan.reminderSentAt != null || timestampMillis(plan.remindAt) > Date.now()) return;
      transaction.update(document.ref, {reminderSentAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp()});
      transaction.create(historyRef, {type: 'sent', createdAt: FieldValue.serverTimestamp()});
      shouldSend = true;
    });
    if (shouldSend) await createNotification(document.data().patientUid, {
      type: 'medication_refill', title: `Refill reminder: ${document.data().name || 'medication'}`,
      body: 'Your recorded supply may be running low. Review your treatment plan and confirm any order yourself.', relatedId: document.id,
    });
  }));
});

