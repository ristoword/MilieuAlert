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
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF6B6B80);

    final selected = path.startsWith('/settings')
        ? 2
        : (navMode ? 1 : 0);

    return Material(
      color: isDark ? NeonColors.darkCard : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: NeonColors.cyan.withValues(alpha: isDark ? 0.45 : 0.28),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: NeonColors.cyan.withValues(alpha: isDark ? 0.16 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              children: [
                _NavTab(
                  selected: selected == 0,
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map,
                  label: l10n?.navMap ?? 'Mappa',
                  color: NeonColors.cyan,
                  muted: muted,
                  onTap: () => context.go(mapLocation),
                ),
                _NavTab(
                  selected: selected == 1,
                  icon: Icons.navigation_outlined,
                  selectedIcon: Icons.navigation,
                  label: l10n?.navNavigation ?? 'Navigazione',
                  color: NeonColors.magenta,
                  muted: muted,
                  onTap: () => context.go(navigationLocation),
                ),
                _NavTab(
                  selected: selected == 2,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: l10n?.settings ?? 'Impostazioni',
                  color: NeonColors.electricBlue,
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
    required this.color,
    required this.muted,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? color : muted,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.exo2(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.5,
                  color: selected ? color : muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
