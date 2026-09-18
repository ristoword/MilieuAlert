const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  computeEntitlement,
  pickTrialStart,
  isComplimentary,
  TRIAL_DAYS,
  PREMIUM_PRICE_EUR,
  PLAY_PRODUCT_ID,
} = require('../entitlement');

describe('MilieuAlert entitlement', () => {
  const now = new Date('2026-09-18T10:00:00.000Z');

  it('keeps full access during the 15-day trial', () => {
    const e = computeEntitlement(
      {
        email: 'new@example.com',
        trial_started_at: '2026-09-10T10:00:00.000Z',
        trial_ends_at: '2026-09-25T10:00:00.000Z',
        is_premium: false,
        subscription_plan: 'free',
      },
      now
    );
    assert.equal(e.trialActive, true);
    assert.equal(e.premium, false);
    assert.equal(e.navigatorOnly, false);
    assert.equal(e.plan, 'trial');
  });

  it('locks to navigator-only after day 15 if unpaid', () => {
    const e = computeEntitlement(
      {
        email: 'late@example.com',
        trial_started_at: '2026-08-01T10:00:00.000Z',
        trial_ends_at: '2026-08-16T10:00:00.000Z',
        is_premium: false,
        subscription_plan: 'free',
      },
      now
    );
    assert.equal(e.trialActive, false);
    assert.equal(e.premium, false);
    assert.equal(e.navigatorOnly, true);
  });

  it('unlocks everything when premium / paid', () => {
    const e = computeEntitlement(
      {
        email: 'paid@example.com',
        trial_started_at: '2026-01-01T00:00:00.000Z',
        trial_ends_at: '2026-01-16T00:00:00.000Z',
        is_premium: true,
        subscription_plan: 'pro',
      },
      now
    );
    assert.equal(e.premium, true);
    assert.equal(e.trialActive, false);
    assert.equal(e.navigatorOnly, false);
  });

  it('never locks complimentary staff accounts', () => {
    for (const user of [
      { email: 'admin@gestionesemplificata.com', is_premium: false },
      { email: 'x@example.com', display_name: 'Giancarlo Borzi', is_premium: false },
      { email: 'x@example.com', display_name: 'Roberto Dasso', is_premium: false },
      { email: 'stefano.montegrande@iochef.it', is_premium: false },
      { email: 'x@example.com', subscription_plan: 'staff', is_premium: false },
    ]) {
      const e = computeEntitlement(
        {
          ...user,
          trial_started_at: '2020-01-01T00:00:00.000Z',
          trial_ends_at: '2020-01-16T00:00:00.000Z',
        },
        now
      );
      assert.equal(e.complimentary, true, user.email || user.display_name);
      assert.equal(e.premium, true);
      assert.equal(e.navigatorOnly, false);
    }
  });

  it('picks the earliest of register, first open, and now', () => {
    const start = pickTrialStart({
      createdAt: '2026-09-10T00:00:00.000Z',
      clientStartedAt: '2026-09-01T00:00:00.000Z',
      now: new Date('2026-09-18T00:00:00.000Z'),
    });
    assert.equal(start.toISOString(), '2026-09-01T00:00:00.000Z');
  });

  it('documents the 2.99 Play product', () => {
    assert.equal(PREMIUM_PRICE_EUR, '2.99');
    assert.equal(PLAY_PRODUCT_ID, 'milieualert_premium_2_99');
    assert.equal(TRIAL_DAYS, 15);
    assert.equal(isComplimentary({ email: 'random@example.com' }), false);
  });
});
