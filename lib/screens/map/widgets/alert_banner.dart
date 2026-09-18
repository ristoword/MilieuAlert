import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../models/zone_status.dart';

class AlertBanner extends StatelessWidget {
  final ZoneProximity? proximity;
  final VoidCallback? onAskAi;

  const AlertBanner({
    super.key,
    this.proximity,
    this.onAskAi,
  });

  @override
  Widget build(BuildContext context) {
    final shouldShow =
        proximity != null && proximity!.status != ZoneStatus.safe;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: shouldShow ? _buildBanner(context) : const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = l10nOf(context);
    late Color color;
    late IconData icon;
    late String title;
    late String subtitle;

    switch (proximity!.status) {
      case ZoneStatus.approaching:
        color = MapsColors.lezOnRouteBorder;
        icon = Icons.shield_outlined;
        final dist = proximity!.distanceMeters?.toInt() ?? 0;
        title = l10n.approachingZoneMeters(dist);
        subtitle = proximity!.isVehicleAllowed == false
            ? l10n.vehicleNotAuthorizedInZone(proximity!.zoneName)
            : proximity!.zoneName;
        break;
      case ZoneStatus.inside:
        if (proximity!.isVehicleAllowed == false) {
          color = MapsColors.endRed;
          icon = Icons.error_outline;
          title = l10n.vehicleNotAuthorized;
          subtitle = proximity!.zoneName;
        } else {
          color = MapsColors.accent;
          icon = Icons.check_circle_outline;
          title = l10n.vehicleAuthorized;
          subtitle = l10n.insideZoneName(proximity!.zoneName);
        }
        break;
      default:
        return const SizedBox.shrink();
    }

    return MapsGlass(
      key: ValueKey('alert_${proximity!.status}_${proximity!.zoneId}'),
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : MapsColors.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : MapsColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (onAskAi != null)
              IconButton(
                tooltip: l10n.askAi,
                onPressed: onAskAi,
                icon: Icon(Icons.auto_awesome, color: color, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
