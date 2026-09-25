import 'package:flutter_test/flutter_test.dart';
import 'package:milieu_alert/models/entitlement.dart';

void main() {
  final now = DateTime.parse('2026-09-18T10:00:00.000Z');

  test('trial is full access for 15 days from first open', () {
    final e = Entitlement.local(
      now: now,
      trialStartedAt: DateTime.parse('2026-09-10T10:00:00.000Z'),
    );
    expect(e.trialActive, isTrue);
    expect(e.navigatorOnly, isFalse);
    expect(e.fullAccess, isTrue);
  });

  test('after day 15 unpaid users are navigator-only', () {
    final e = Entitlement.local(
      now: now,
      trialStartedAt: DateTime.parse('2026-08-01T10:00:00.000Z'),
    );
    expect(e.trialActive, isFalse);
    expect(e.navigatorOnly, isTrue);
    expect(e.fullAccess, isFalse);
  });

  test('paid and complimentary stay unlocked', () {
    expect(
      Entitlement.local(now: now, premium: true).navigatorOnly,
      isFalse,
    );
    expect(
      Entitlement.isComplimentaryIdentity(
        'admin@gestionesemplificata.com',
        null,
      ),
      isTrue,
    );
    expect(
      Entitlement.isComplimentaryIdentity(null, 'Giancarlo Borzi'),
      isTrue,
    );
    expect(
      Entitlement.isComplimentaryIdentity(null, 'Roberto Dasso'),
      isTrue,
    );
    expect(
      Entitlement.isComplimentaryIdentity(
        'francibasile603@gmail.com',
        'Francesco Basile',
      ),
      isTrue,
    );
    expect(Entitlement.playProductId, 'milieualert_premium_2_99');
    expect(Entitlement.priceEur, '1.99');
  });
}
