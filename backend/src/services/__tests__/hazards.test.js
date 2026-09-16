const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const {
  isHazardType,
  isCameraType,
  ttlMsFor,
  expiresAtFrom,
  clampNote,
  clampComment,
  voterKey,
  shouldExpireFromVotes,
  nextExpiryOnConfirm,
  toPublicReport,
  mergeCameras,
  CAMERA_TYPES,
} = require('../hazards');

describe('crowdsourced hazards', () => {
  it('accepts Flitsmeister report types and camera kinds', () => {
    assert.equal(isHazardType('camera_mobile'), true);
    assert.equal(isHazardType('accident'), true);
    assert.equal(isHazardType('lez_extra'), true);
    assert.equal(isHazardType('malware'), false);
    assert.equal(isCameraType('camera_fixed'), true);
    assert.equal(isCameraType('jam'), false);
    assert.ok(CAMERA_TYPES.includes('camera_mobile'));
  });

  it('expires mobile cameras ~2h and accidents ~1h', () => {
    const twoH = 2 * 3600 * 1000;
    const oneH = 3600 * 1000;
    assert.equal(ttlMsFor('camera_mobile'), twoH);
    assert.equal(ttlMsFor('accident'), oneH);
    assert.ok(ttlMsFor('camera_fixed') > twoH);
    const now = new Date('2026-01-01T00:00:00Z');
    assert.equal(
      expiresAtFrom('accident', now).toISOString(),
      '2026-01-01T01:00:00.000Z'
    );
  });

  it('hides reporter identity in public payloads', () => {
    const pub = toPublicReport({
      id: 'abc',
      user_id: 'secret-user',
      device_id: 'secret-device',
      type: 'camera_mobile',
      lat: 45.46,
      lon: 9.19,
      heading: 90,
      note: 'dietro il cartello',
      created_at: 't',
      expires_at: 'e',
      confirm_count: 3,
      deny_count: 1,
    });
    assert.equal(pub.author, 'un conducente');
    assert.equal(pub.source, 'community');
    assert.equal(pub.user_id, undefined);
    assert.equal(pub.device_id, undefined);
    assert.equal(JSON.stringify(pub).includes('secret'), false);
  });

  it('decays unofficial cameras when denies outpace confirms', () => {
    assert.equal(shouldExpireFromVotes(0, 2), true);
    assert.equal(shouldExpireFromVotes(3, 4), false);
    assert.equal(shouldExpireFromVotes(1, 3), true);
  });

  it('extends expiry on confirm without exceeding the cap', () => {
    const now = new Date('2026-01-01T00:00:00Z');
    const current = new Date('2026-01-01T01:00:00Z');
    const next = nextExpiryOnConfirm('camera_mobile', current, now);
    assert.ok(next.getTime() > current.getTime());
    assert.ok(next.getTime() <= now.getTime() + 8 * 3600 * 1000);
  });

  it('merges OSM and community cameras with distinct ids', () => {
    const merged = mergeCameras(
      [{ id: '111', lat: 1, lon: 2, maxspeed: '50' }],
      [{ id: 'uuid-9', type: 'camera_mobile', lat: 3, lon: 4, confirm_count: 2 }]
    );
    assert.equal(merged[0].source, 'osm');
    assert.equal(merged[1].source, 'community');
    assert.equal(merged[1].id, 'c-uuid-9');
    assert.equal(merged[1].reportId, 'uuid-9');
  });

  it('clamps notes and builds voter keys without leaking emails', () => {
    assert.equal(clampNote('  ciao   mondo  ').length < 280, true);
    assert.equal(clampComment('x').length, 1);
    assert.equal(voterKey({ userId: 'u1' }), 'u:u1');
    assert.equal(voterKey({ deviceId: 'abcdefgh' }), 'd:abcdefgh');
    assert.equal(voterKey({ deviceId: 'short' }), null);
  });
});
