import 'package:flutter/material.dart';
import '../../../models/zone_status.dart';
import '../../../core/constants.dart';

class StatusBar extends StatelessWidget {
  final double? speed;
  final ZoneProximity? proximity;

  const StatusBar({
    super.key,
    this.speed,
    this.proximity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final speedKmh = (speed ?? 0) * 3.6;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (proximity == null) {
      statusColor = AppConstants.zoneSafeBorder;
      statusText = 'No zones nearby';
      statusIcon = Icons.check_circle;
    } else {
      switch (proximity!.status) {
        case ZoneStatus.safe:
          statusColor = AppConstants.zoneSafeBorder;
          statusText = proximity!.zoneName;
          statusIcon = Icons.check_circle;
        case ZoneStatus.approaching:
          statusColor = AppConstants.zoneApproachingBorder;
          statusText =
              '${proximity!.zoneName} - ${proximity!.distanceMeters?.toInt() ?? "?"}m';
          statusIcon = Icons.warning;
        case ZoneStatus.inside:
          statusColor = AppConstants.zoneInsideBorder;
          statusText = proximity!.zoneName;
          statusIcon = proximity!.isVehicleAllowed == true
              ? Icons.check_circle
              : Icons.error;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.speed,
                        size: 20,
                        color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      '${speedKmh.toInt()} km/h',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statusText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
