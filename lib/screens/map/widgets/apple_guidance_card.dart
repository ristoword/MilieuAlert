import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../models/navigation_models.dart';
import '../../../models/zone_status.dart';
import '../../../providers/navigation_provider.dart';

IconData mapsTurnIcon(NavStep? step) {
  if (step == null) return Icons.navigation_rounded;
  switch (step.type) {
    case 'arrive':
      return Icons.flag_rounded;
    case 'roundabout':
    case 'rotary':
      return Icons.roundabout_left;
    case 'on ramp':
      return Icons.merge_type;
    case 'off ramp':
    case 'exit':
      return Icons.logout;
    case 'merge':
      return Icons.merge;
    case 'fork':
    case 'turn':
      if (step.modifier.contains('uturn')) return Icons.u_turn_left;
      if (step.modifier.contains('left')) return Icons.turn_left;
      if (step.modifier.contains('right')) return Icons.turn_right;
      return Icons.arrow_upward_rounded;
    case 'depart':
    case 'continue':
    case 'new name':
    default:
      return Icons.arrow_upward_rounded;
  }
}

String mapsInstruction(LiveNavInfo? live, NavigationState nav) {
  final step = live?.currentStep;
  if (step != null) {
    final text = step.instructionIt;
    if (step.type == 'arrive') return text;
    final dist = formatDistance(step.distanceMeters);
    if (dist == '—' || step.distanceMeters <= 0) return text;
    return text;
  }
  if (nav.destination != null) {
    return 'Verso ${nav.destination!.label}';
  }
  if (nav.hasRoute) return 'Percorso pronto';
  return 'Nessun percorso';
}

class AppleGuidanceCard extends StatelessWidget {
  const AppleGuidanceCard({
    super.key,
    required this.nav,
    required this.live,
  });

  final NavigationState nav;
  final LiveNavInfo? live;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = live?.currentStep;
    final dist = step != null && step.distanceMeters > 0
        ? formatDistance(step.distanceMeters)
        : formatDistance(live?.remainingMeters ?? nav.routeDistanceMeters);
    final action = step?.maneuverIt ?? mapsInstruction(live, nav);
    final street = step?.name.trim().isNotEmpty == true
        ? step!.name
        : (nav.destination?.label ?? '');

    return MapsGlass(
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: MapsColors.route.withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                mapsTurnIcon(step),
                color: MapsColors.route,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dist,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      height: 1.05,
                      color: isDark ? Colors.white : MapsColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : MapsColors.ink,
                    ),
                  ),
                  if (street.isNotEmpty)
                    Text(
                      street,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : MapsColors.inkMuted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
