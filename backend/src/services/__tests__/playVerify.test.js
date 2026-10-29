const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { evaluateSubscription } = require('../playVerify');

const now = new Date('2026-11-01T00:00:00.000Z');
const product = 'milieualert_premium_2_99';

describe('Play subscription verification', () => {
  it('accepts an active subscription for our product', () => {
    const r = evaluateSubscription(
      {
        subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
        acknowledgementState: 'ACKNOWLEDGEMENT_STATE_PENDING',
        lineItems: [{ productId: product, expiryTime: '2026-12-01T00:00:00Z' }],
      },
      product,
      now
    );
    assert.equal(r.active, true);
    assert.equal(r.needsAck, true);
    assert.equal(r.expiresAt.toISOString(), '2026-12-01T00:00:00.000Z');
  });

  it('rejects expired, cancelled-and-lapsed, or other products', () => {
    for (const sub of [
      {
        subscriptionState: 'SUBSCRIPTION_STATE_EXPIRED',
        lineItems: [{ productId: product, expiryTime: '2026-12-01T00:00:00Z' }],
      },
      {
        subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
        lineItems: [{ productId: product, expiryTime: '2026-10-01T00:00:00Z' }],
      },
      {
        subscriptionState: 'SUBSCRIPTION_STATE_ACTIVE',
        lineItems: [{ productId: 'other', expiryTime: '2026-12-01T00:00:00Z' }],
      },
      null,
    ]) {
      assert.equal(evaluateSubscription(sub, product, now).active, false);
    }
  });

  it('keeps access during the grace period', () => {
    const r = evaluateSubscription(
      {
        subscriptionState: 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
        acknowledgementState: 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED',
        lineItems: [{ productId: product, expiryTime: '2026-11-05T00:00:00Z' }],
      },
      product,
      now
    );
    assert.equal(r.active, true);
    assert.equal(r.needsAck, false);
  });
});
