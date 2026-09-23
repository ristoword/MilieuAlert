import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../models/navigation_models.dart';
import '../../../models/zone_status.dart';
import '../../../providers/navigation_provider.dart';
import '../../../services/navigation_guidance.dart';
import 'lane_guidance.dart';
import 'live_speed_chip.dart';

IconData mapsTurnIcon(NavStep? step) {
  if (step == null) return Icons.navigation_rounded;
  switch (step.type) {
    case 'arrive':
      return Icons.flag_rounded;
    case 'walk':
      return Icons.directions_walk_rounded;
    case 'tram':
      return Icons.tram_rounded;
    case 'bus':
      return Icons.directions_bus_rounded;
    case 'subway':
      return Icons.subway_rounded;
    case 'rail':
      return Icons.train_rounded;
    case 'ferry':
      return Icons.directions_boat_rounded;
    case 'transit':
      return Icons.directions_transit_rounded;
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
    case 'use lane':
      return Icons.view_column_rounded;
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

String mapsInstruction(
  LiveNavInfo? live,
  NavigationState nav, [
  AppLocalizations? l10n,
]) {
  final t = l10n;
  if (nav.recalculating || live?.offRoute == true) {
    return t?.recalculatingRoute ?? 'Ricalcolo percorso';
  }
  if (nav.usingDropOff &&
      !nav.walkLegActive &&
      live?.currentStep?.type == 'arrive') {
    final walk = formatDistance(nav.walkMeters);
    return t?.stopThenWalk(walk) ?? 'Sosta, poi $walk a piedi';
  }
  if (nav.walkLegActive) {
    final step = live?.currentStep;
    if (step != null && step.type != 'arrive') return step.instructionIt;
    return t?.walkTowardsDestination ?? 'Cammina verso destinazione';
  }
  final step = live?.currentStep;
  if (step != null) return step.instructionIt;
  if (nav.destination != null) {
    return t?.towardsDestination(nav.destination!.label) ??
        'Verso ${nav.destination!.label}';
  }
  if (nav.hasRoute) return t?.routeReady ?? 'Percorso pronto';
  return t?.noRoute ?? 'Nessun percorso';
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
    final l10n = l10nOf(context);
    final rerouting = nav.recalculating || live?.offRoute == true;
    final step = live?.currentStep;
    final meters = live?.metersToManeuver ??
        live?.remainingMeters ??
        nav.routeDistanceMeters;
    final dist = formatDistance(meters);
    final nearAlight =
        step?.isTransitVehicle == true && (meters ?? 9999) <= 80;
    final action = rerouting
        ? l10n.recalculatingRoute
        : nav.walkLegActive && (step == null || step.type == 'arrive')
            ? l10n.walkTowardsDestination
            : nearAlight
                ? (step?.alightActionIt ?? mapsInstruction(live, nav, l10n))
                : (step?.maneuverIt ?? mapsInstruction(live, nav, l10n));
    var street = rerouting
        ? (nav.destination?.label ?? '')
        : (step?.hudSubtitle(metersToManeuver: meters) ?? '');
    if (street.isEmpty &&
        step?.isWalkAction != true &&
        step?.isTransitVehicle != true) {
      street = nav.destination?.label ?? '';
    }
    if (nav.usingDropOff && !nav.walkLegActive && !rerouting) {
      street = l10n.thenWalk(formatDistance(nav.walkMeters));
    }
    final lanes = !rerouting && nav.mode.isCar
        ? lanesForHud(
            steps: nav.steps,
            stepIndex: live?.stepIndex ?? 0,
            metersToManeuver: meters ?? 9999,
          )
        : const <NavLane>[];
    final icon = rerouting
        ? Icons.sync_rounded
        : nav.walkLegActive
            ? Icons.directions_walk_rounded
            : mapsTurnIcon(step);

    return MapsGlass(
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: MapsColors.route.withValues(alpha: isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
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
                const SizedBox(width: 8),
                if (nav.mode.isCar)
                  LiveSpeedChip(
                    speedKmh: live?.speedKmh,
                    limitKmh: live?.speedLimitKmh,
                    speeding: live?.speeding == true,
                  ),
              ],
            ),
            if (lanes.isNotEmpty) LaneGuidanceRow(lanes: lanes),
          ],
        ),
      ),
    );
  }
}
