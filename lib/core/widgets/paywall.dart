import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../../l10n/l10n_ext.dart';
import '../../models/entitlement.dart';
import '../../providers/entitlement_provider.dart';

Future<void> showPaywallSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const PaywallSheet(),
  );
}

void guardPremium(
  BuildContext context,
  WidgetRef ref, {
  required VoidCallback ifAllowed,
}) {
  if (ref.read(entitlementProvider).fullAccess) {
    ifAllowed();
    return;
  }
  showPaywallSheet(context);
}

class PaywallSettingsCard extends ConsumerWidget {
  const PaywallSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = ref.watch(entitlementProvider);
    final l10n = l10nOf(context);
    final theme = Theme.of(context);
    if (e.premium) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.workspace_premium, color: theme.colorScheme.primary),
          title: Text(e.complimentary ? l10n.complimentaryAccount : l10n.premiumActive),
          subtitle: Text(l10n.premiumUnlockedFeatures),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: Icon(
          e.trialActive ? Icons.timer_outlined : Icons.lock_outline,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          e.trialActive
              ? l10n.paywallTrialDays(e.daysLeft)
              : l10n.paywallExpiredTitle,
        ),
        subtitle: Text(l10n.paywallExpiredBody),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showPaywallSheet(context),
      ),
    );
  }
}

class PaywallBanner extends ConsumerWidget {
  const PaywallBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = ref.watch(entitlementProvider);
    if (e.premium) return const SizedBox.shrink();
    final l10n = l10nOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (e.trialActive) {
      return _BannerCard(
        isDark: isDark,
        icon: Icons.timer_outlined,
        title: l10n.paywallTrialDays(e.daysLeft),
        subtitle: l10n.paywallTrialHint,
        cta: l10n.paywallUnlock,
        onTap: () => showPaywallSheet(context),
      );
    }
    return _BannerCard(
      isDark: isDark,
      icon: Icons.lock_outline,
      title: l10n.paywallExpiredTitle,
      subtitle: l10n.paywallExpiredBody,
      cta: l10n.paywallUnlock,
      onTap: () => showPaywallSheet(context),
      emphasize: true,
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
    this.emphasize = false,
  });

  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MapsGlass(
        radius: 16,
        tint: emphasize
            ? (isDark
                ? const Color(0xE61C1C1E)
                : const Color(0xF7FFFFFF))
            : null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Icon(icon, color: MapsColors.accent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : MapsColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          height: 1.25,
                          color: isDark ? Colors.white70 : MapsColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  cta.split('—').first.trim(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: MapsColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaywallSheet extends ConsumerStatefulWidget {
  const PaywallSheet({super.key});

  @override
  ConsumerState<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<PaywallSheet> {
  final _codeCtrl = TextEditingController();
  bool _busy = false;
  String? _msg;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _buy() async {
    setState(() {
      _busy = true;
      _msg = null;
    });
    final result = await ref.read(entitlementProvider.notifier).upgrade();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _msg = result.message;
    });
    if (result.ok && result.entitlement?.premium == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _redeem() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _busy = true;
      _msg = null;
    });
    final result = await ref.read(entitlementProvider.notifier).redeem(code);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _msg = result.message;
    });
    if (result.ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final e = ref.watch(entitlementProvider);
    final ink = isDark ? Colors.white : MapsColors.ink;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: MapsGlass(
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: MapsColors.inkMuted.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                e.trialActive
                    ? l10n.paywallTrialTitle
                    : l10n.paywallExpiredTitle,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.paywallExpiredBody,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? Colors.white70 : MapsColors.inkMuted,
                ),
              ),
              const SizedBox(height: 16),
              _Feature(text: l10n.paywallFeatureAlerts),
              _Feature(text: l10n.paywallFeatureCameras),
              _Feature(text: l10n.paywallFeatureEcoentry),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _busy ? null : _buy,
                style: FilledButton.styleFrom(
                  backgroundColor: MapsColors.accent,
                  foregroundColor: const Color(0xFF041016),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.paywallUnlock,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                      ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeCtrl,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: l10n.paywallRedeem,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: _busy ? null : _redeem,
                    icon: const Icon(Icons.check),
                  ),
                ),
                onSubmitted: (_) => _redeem(),
              ),
              if (_msg != null) ...[
                const SizedBox(height: 8),
                Text(
                  _msg!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : MapsColors.inkMuted,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.playBillingLine(Entitlement.playProductId, Entitlement.priceEur),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: MapsColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: MapsColors.accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
