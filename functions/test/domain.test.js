const test = require('node:test');
const assert = require('node:assert/strict');

const {allowedTransitions, finiteNonNegative, inventoryKey, orderSubtotal} = require('../domain');

test('order transition policy only permits the expected next step', () => {
  assert.equal(allowedTransitions.confirmed.has('processing'), true);
  assert.equal(allowedTransitions.dispatched.has('processing'), false);
  assert.equal(allowedTransitions.delivered, undefined);
});

test('inventory keys normalize medicine fields consistently', () => {
  assert.equal(inventoryKey('Medicine A', '10 mg', 'Tablet'), inventoryKey(' medicine a ', '10 MG', 'tablet'));
  assert.notEqual(inventoryKey('Medicine A', '10 mg', 'Tablet'), inventoryKey('Medicine A', '20 mg', 'Tablet'));
});

test('prices and totals reject negative or non-finite amounts', () => {
  assert.equal(finiteNonNegative(0), true);
  assert.equal(finiteNonNegative(12.5), true);
  assert.equal(finiteNonNegative(-1), false);
  assert.equal(finiteNonNegative(Number.NaN), false);
  assert.equal(orderSubtotal([{quantity: 2, unitPrice: 3.5}]), 7);
  assert.equal(Number.isNaN(orderSubtotal([{quantity: 0, unitPrice: 3.5}])), true);
});
