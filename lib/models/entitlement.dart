class Entitlement {
  static const int trialDays = 15;
  static const String priceEur = '2.99';
  static const String playProductId = 'milieualert_premium_2_99';
  static const String gsCheckoutUrl =
      'https://gestionesemplificata.com/prodotti#milieualert';

  const Entitlement({
    required this.trialActive,
    required this.premium,
    required this.navigatorOnly,
    this.complimentary = false,
    this.trialStartedAt,
    this.trialEndsAt,
    this.plan = 'trial',
  });

  final bool trialActive;
  final bool premium;
  final bool navigatorOnly;
  final bool complimentary;
  final DateTime? trialStartedAt;
  final DateTime? trialEndsAt;
  final String plan;

  bool get fullAccess => premium || trialActive;
  bool get locked => navigatorOnly;

  int get daysLeft {
    final end = trialEndsAt;
    if (end == null) return 0;
    final remaining = end.difference(DateTime.now()).inDays;
    if (remaining < 0) return 0;
    return remaining;
  }

  Entitlement copyWith({
    bool? trialActive,
    bool? premium,
    bool? navigatorOnly,
    bool? complimentary,
    DateTime? trialStartedAt,
    DateTime? trialEndsAt,
    String? plan,
  }) {
    return Entitlement(
      trialActive: trialActive ?? this.trialActive,
      premium: premium ?? this.premium,
      navigatorOnly: navigatorOnly ?? this.navigatorOnly,
      complimentary: complimentary ?? this.complimentary,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      plan: plan ?? this.plan,
    );
  }

  factory Entitlement.fromJson(Map<String, dynamic>? json, {DateTime? now}) {
    now ??= DateTime.now();
    if (json == null) {
      return Entitlement.local(now: now);
    }
    return Entitlement(
      trialActive: json['trialActive'] == true,
      premium: json['premium'] == true,
      navigatorOnly: json['navigatorOnly'] == true,
      complimentary: json['complimentary'] == true,
      trialStartedAt: _parse(json['trialStartedAt'] ?? json['trial_started_at']),
      trialEndsAt: _parse(json['trialEndsAt'] ?? json['trial_ends_at']),
      plan: (json['plan'] as String?) ?? 'trial',
    );
  }

  /// Local clock used when the API is unreachable.
  factory Entitlement.local({
    required DateTime now,
    DateTime? trialStartedAt,
    bool premium = false,
    bool complimentary = false,
    String? email,
    String? displayName,
  }) {
    final comp = complimentary || isComplimentaryIdentity(email, displayName);
    if (comp || premium) {
      return Entitlement(
        trialActive: false,
        premium: true,
        navigatorOnly: false,
        complimentary: comp,
        trialStartedAt: trialStartedAt,
        trialEndsAt: trialStartedAt?.add(const Duration(days: trialDays)),
        plan: comp ? 'comp' : 'pro',
      );
    }
    final start = trialStartedAt ?? now;
    final end = start.add(const Duration(days: trialDays));
    final active = now.isBefore(end);
    return Entitlement(
      trialActive: active,
      premium: false,
      navigatorOnly: !active,
      trialStartedAt: start,
      trialEndsAt: end,
      plan: active ? 'trial' : 'navigator',
    );
  }

  static DateTime? _parse(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString());
  }

  static bool isComplimentaryIdentity(String? email, String? displayName) {
    final hay = '${email ?? ''} ${displayName ?? ''}'.toLowerCase();
    if (hay.trim().isEmpty) return false;
    const emails = {
      'admin@gestionesemplificata.com',
      'assistenza@gestionesemplificata.com',
      'info@gestionesemplificata.com',
      'stefano.montegrande@iochef.it',
      'chef@iochef.it',
    };
    final mail = (email ?? '').trim().toLowerCase();
    if (emails.contains(mail) || mail.startsWith('admin@')) return true;
    return hay.contains('giancarlo borzi') ||
        hay.contains('roberto dasso') ||
        hay.contains('stefano montegrande') ||
        hay.contains('borzi') ||
        hay.contains('dasso');
  }
}
