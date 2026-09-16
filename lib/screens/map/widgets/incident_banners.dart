import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../models/emission_zone.dart';
import '../../../models/navigation_models.dart';
import '../../../models/zone_status.dart';

class IncidentBanner extends StatelessWidget {
  const IncidentBanner({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color = MapsColors.lezOnRouteBorder,
    this.onAskAi,
    this.onDismiss,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onAskAi;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MapsGlass(
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
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
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
                tooltip: 'Chiedi all\'AI',
                onPressed: onAskAi,
                icon: Icon(Icons.auto_awesome, color: color, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            if (onDismiss != null)
              IconButton(
                tooltip: 'Chiudi',
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.white54 : MapsColors.inkMuted,
                  size: 18,
                ),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

class RouteChangeBanners extends StatelessWidget {
  const RouteChangeBanners({
    super.key,
    required this.alerts,
    required this.onDismiss,
    this.onAskAi,
  });

  final List<RouteChangeAlert> alerts;
  final ValueChanged<String> onDismiss;
  final ValueChanged<RouteChangeAlert>? onAskAi;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final alert in alerts.take(3)) ...[
          IncidentBanner(
            icon: _iconFor(alert.kind),
            title: alert.title,
            subtitle: alert.message,
            color: alert.critical ? MapsColors.endRed : const Color(0xFFFF9F0A),
            onAskAi: onAskAi == null ? null : () => onAskAi!(alert),
            onDismiss: () => onDismiss(alert.id),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  IconData _iconFor(RouteAlertKind kind) {
    switch (kind) {
      case RouteAlertKind.delay:
        return Icons.schedule;
      case RouteAlertKind.faster:
        return Icons.speed;
      case RouteAlertKind.detour:
        return Icons.alt_route;
      case RouteAlertKind.newCamera:
        return Icons.videocam;
      case RouteAlertKind.newZone:
        return Icons.shield;
      case RouteAlertKind.zoneActivating:
        return Icons.warning_amber_rounded;
      case RouteAlertKind.zoneExpiring:
        return Icons.timer_off;
    }
  }
}

class RouteZoneBanner extends StatelessWidget {
  const RouteZoneBanner({super.key, required this.zones});
  final List<EmissionZone> zones;

  @override
  Widget build(BuildContext context) {
    return IncidentBanner(
      icon: Icons.shield_outlined,
      color: MapsColors.lezOnRouteBorder,
      title: 'Milieuzone sul percorso',
      subtitle: '${zones.length} zona/e: ${zones.map((z) => z.name).take(3).join(' · ')}',
    );
  }
}

class CameraIncidentBanner extends StatelessWidget {
  const CameraIncidentBanner({
    super.key,
    required this.meters,
    this.maxspeed,
    this.community = false,
  });

  final double? meters;
  final String? maxspeed;
  final bool community;

  @override
  Widget build(BuildContext context) {
    return IncidentBanner(
      icon: community ? Icons.videocam_outlined : Icons.videocam_outlined,
      color: community ? const Color(0xFFFF3B30) : const Color(0xFFFF9F0A),
      title: 'Autovelox tra ${formatDistance(meters)}',
      subtitle: community
          ? (maxspeed != null
              ? 'Limite $maxspeed km/h · segnalato da un conducente'
              : 'Non in mappa ufficiale · segnalato da un conducente')
          : (maxspeed != null
              ? 'Limite $maxspeed km/h'
              : 'Controllo velocità in avvicinamento'),
    );
  }
}

class CrowdHazardBanner extends StatelessWidget {
  const CrowdHazardBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.onDismiss,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IncidentBanner(
        icon: icon,
        title: title,
        subtitle: subtitle,
        color: color,
        onDismiss: onDismiss,
      ),
    );
  }
}
