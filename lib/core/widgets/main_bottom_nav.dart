import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// Persistent driver chrome: Mappa | Navigazione | Impostazioni.
/// Navigazione opens `/map?nav=1` (same map, A→B panel focused).
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  static const mapLocation = '/map';
  static const navigationLocation = '/map?nav=1';
  static const settingsLocation = '/settings';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uri = GoRouterState.of(context).uri;
    final path = uri.path;
    final navMode = uri.queryParameters['nav'] == '1';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : MapsColors.inkMuted;

    final selected = path.startsWith('/settings')
        ? 2
        : (navMode ? 1 : 0);

    return Material(
      color: isDark ? MapsColors.glassDark : MapsColors.glassLight,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Row(
              children: [
                _NavTab(
                  selected: selected == 0,
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map,
                  label: l10n?.navMap ?? 'Mappa',
                  muted: muted,
                  onTap: () => context.go(mapLocation),
                ),
                _NavTab(
                  selected: selected == 1,
                  icon: Icons.navigation_outlined,
                  selectedIcon: Icons.navigation,
                  label: l10n?.navNavigation ?? 'Navigazione',
                  muted: muted,
                  onTap: () => context.go(navigationLocation),
                ),
                _NavTab(
                  selected: selected == 2,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: l10n?.settings ?? 'Impostazioni',
                  muted: muted,
                  onTap: () => context.go(settingsLocation),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.muted,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = MapsColors.accent;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? tint : muted,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? tint : muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
