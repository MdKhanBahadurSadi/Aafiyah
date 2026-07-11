const allowedTransitions = {
  confirmed: new Set(['processing', 'cancelled']),
  processing: new Set(['dispatched', 'cancelled']),
  dispatched: new Set(['delivered']),
};

function inventoryKey(name, strength, formulation) {
  return Buffer.from(
    `${String(name || '').trim().toLowerCase()}|${String(strength || '').trim().toLowerCase()}|${String(formulation || '').trim().toLowerCase()}`,
  ).toString('base64url');
}

function finiteNonNegative(value) {
  return typeof value === 'number' && Number.isFinite(value) && value >= 0;
}

function orderSubtotal(items) {
  if (!Array.isArray(items)) return NaN;
  return items.reduce((sum, item) => {
    if (!Number.isInteger(item?.quantity) || item.quantity < 1 || !finiteNonNegative(item?.unitPrice)) return NaN;
    return sum + item.quantity * item.unitPrice;
  }, 0);
}

module.exports = {allowedTransitions, finiteNonNegative, inventoryKey, orderSubtotal};
