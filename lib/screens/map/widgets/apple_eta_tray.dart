import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../models/navigation_models.dart';
import '../../../models/zone_status.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/navigation_provider.dart';
import 'live_speed_chip.dart';

class AppleEtaTray extends StatelessWidget {
  const AppleEtaTray({
    super.key,
    required this.location,
    required this.nav,
    required this.live,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onStop,
    required this.onOverview,
    required this.onRecenter,
    required this.onSelectAlternative,
    this.onOpenAi,
  });

  final LocationState location;
  final NavigationState nav;
  final LiveNavInfo? live;
  final bool expanded;
  final ValueChanged<bool?> onToggleExpanded;
  final VoidCallback onStop;
  final VoidCallback onOverview;
  final VoidCallback onRecenter;
  final ValueChanged<int> onSelectAlternative;
  final VoidCallback? onOpenAi;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        final v = details.velocity.pixelsPerSecond.dy;
        if (v < -180) {
          onToggleExpanded(true);
        } else if (v > 180) {
          onToggleExpanded(false);
        }
      },
      child: MapsGlass(
        radius: MapsColors.radiusSheet,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.bottomCenter,
          child: expanded ? _expanded(context) : _collapsed(context),
        ),
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: MapsColors.inkMuted.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }

  Widget _collapsed(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingM = live?.remainingMeters ?? nav.routeDistanceMeters;
    final remainingS = live?.remainingSeconds ?? nav.routeDurationSeconds;
    final ink = isDark ? Colors.white : MapsColors.ink;

    return InkWell(
      onTap: () => onToggleExpanded(true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatEtaClock(remainingS),
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          height: 1.05,
                          color: ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatDuration(remainingS)}  ·  ${formatDistance(remainingM)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.65)
                              : MapsColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (nav.mode.isCar) ...[
                  LiveSpeedChip(
                    speedKmh: live?.speedKmh,
                    limitKmh: live?.speedLimitKmh,
                    speeding: live?.speeding == true,
                    compact: true,
                  ),
                  const SizedBox(width: 8),
                ],
                _EndButton(onStop: onStop),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _expanded(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = l10nOf(context);
    final remainingM = live?.remainingMeters ?? nav.routeDistanceMeters;
    final remainingS = live?.remainingSeconds ?? nav.routeDurationSeconds;
    final zone = location.nearestZone;
    final ink = isDark ? Colors.white : MapsColors.ink;
    final muted = isDark ? Colors.white70 : MapsColors.inkMuted;
    final tracking = location.follow;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => onToggleExpanded(false),
            behavior: HitTestBehavior.opaque,
            child: _handle(),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatEtaClock(remainingS),
                      style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: ink,
                      ),
                    ),
                    Text(
                      '${formatDuration(remainingS)}  ·  ${formatDistance(remainingM)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (nav.mode.isCar) ...[
                LiveSpeedChip(
                  speedKmh: live?.speedKmh,
                  limitKmh: live?.speedLimitKmh,
                  speeding: live?.speeding == true,
                  compact: true,
                ),
                const SizedBox(width: 8),
              ],
              _EndButton(onStop: onStop),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.shield_outlined,
            color: nav.zonesOnRoute.isEmpty
                ? MapsColors.accent
                : MapsColors.lezOnRouteBorder,
            title: nav.zonesOnRoute.isEmpty
                ? l10n.noLezOnRoute
                : l10n.zonesCountEnvironmental(nav.zonesOnRoute.length),
            subtitle: nav.zonesOnRoute.isEmpty
                ? l10n.routeAvoidsLez
                : nav.zonesOnRoute.map((z) => z.name).take(3).join(' · '),
          ),
          if (nav.usingDropOff) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.directions_walk_rounded,
              color: MapsColors.accent,
              title: nav.walkLegActive
                  ? l10n.walkLeg
                  : l10n.dropoffRecommended,
              subtitle: nav.walkLegActive
                  ? l10n.walkTowards(
                      nav.destination?.label ?? l10n.destinationGeneric)
                  : l10n.walkAfterStop(formatDistance(nav.walkMeters)),
            ),
          ],
          if (nav.mode.isTransit) ...[
            const SizedBox(height: 10),
            _TransitLegsList(nav: nav),
          ],
          if (zone != null && zone.status != ZoneStatus.safe) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.warning_amber_rounded,
              color: zone.isVehicleAllowed == false
                  ? MapsColors.endRed
                  : MapsColors.lezOnRouteBorder,
              title: zone.isVehicleAllowed == false
                  ? l10n.vehicleNotAuthorized
                  : l10n.nearbyEnvironmentalZone,
              subtitle:
                  '${zone.zoneName} · ${formatDistance(zone.distanceMeters)}',
            ),
          ],
          if (nav.mode.isCar && live?.nextCamera != null) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.videocam_outlined,
              color: const Color(0xFFFF9F0A),
              title:
                  l10n.speedCameraIn(formatDistance(live!.nextCameraMeters)),
              subtitle: live!.nextCamera!.maxspeed != null
                  ? l10n.speedLimitKmh('${live!.nextCamera!.maxspeed}')
                  : l10n.speedCheckOnRoute,
            ),
          ],
          if (nav.mode.isCar &&
              nav.cameras.isNotEmpty &&
              live?.nextCamera == null) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.videocam_outlined,
              color: const Color(0xFFFF9F0A),
              title: l10n.camerasOnRoute(nav.cameras.length),
              subtitle: l10n.camerasAsPins,
            ),
          ],
          if (nav.alternatives.length > 1) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: nav.alternatives.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final plan = nav.alternatives[i];
                  final selected = i == nav.selectedRoute;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(
                      '${plan.chipLabelIt(i)} · ${formatDuration(plan.durationSeconds)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : (isDark ? Colors.white : MapsColors.ink),
                      ),
                    ),
                    selectedColor: MapsColors.route,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFF2F2F7),
                    onSelected: (_) => onSelectAlternative(i),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TrayAction(
                  icon: tracking ? Icons.gps_fixed : Icons.explore_outlined,
                  label: tracking ? l10n.centered : l10n.recenter,
                  onTap: onRecenter,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TrayAction(
                  icon: Icons.map_outlined,
                  label: l10n.overview,
                  onTap: onOverview,
                ),
              ),
              if (onOpenAi != null) ...[
                const SizedBox(width: 8),
                _TrayAction(
                  icon: Icons.auto_awesome,
                  label: 'AI',
                  onTap: onOpenAi!,
                  compact: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TransitLegsList extends StatelessWidget {
  const _TransitLegsList({required this.nav});

  final NavigationState nav;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    TransitItinerary? itinerary;
    if (nav.selectedRoute >= 0 &&
        nav.selectedRoute < nav.alternatives.length) {
      itinerary = nav.alternatives[nav.selectedRoute].itinerary;
    }
    final legs = itinerary?.legs ?? const <TransitLeg>[];
    if (legs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          itinerary!.transfers == 0
              ? l10nOf(context).transitNoTransfers
              : l10nOf(context).transitTransfers(itinerary.transfers),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: isDark ? Colors.white70 : MapsColors.inkMuted,
          ),
        ),
        const SizedBox(height: 6),
        for (final leg in legs)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _DetailRow(
              icon: leg.isWalk
                  ? Icons.directions_walk_rounded
                  : Icons.directions_transit_rounded,
              color: MapsColors.route,
              title: leg.actionIt,
              subtitle: leg.isWalk
                  ? formatDistance(leg.distanceMeters)
                  : '${leg.boardIt} · ${leg.alightIt}',
            ),
          ),
      ],
    );
  }
}

class _EndButton extends StatelessWidget {
  const _EndButton({required this.onStop});
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onStop,
      style: FilledButton.styleFrom(
        backgroundColor: MapsColors.endRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 0,
      ),
      child: Text(
        l10nOf(context).endNav,
        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : MapsColors.ink,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : MapsColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrayAction extends StatelessWidget {
  const _TrayAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: compact ? 12 : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: MapsColors.accent),
              if (!compact) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? Colors.white : MapsColors.ink,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
