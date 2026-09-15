import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/zone_provider.dart';
import '../../models/emission_zone.dart';

class ZoneDetailScreen extends ConsumerWidget {
  final String zoneId;

  const ZoneDetailScreen({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(zonesProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zone Details'),
      ),
      body: zonesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (zones) {
          final zone = zones.where((z) => z.id == zoneId).firstOrNull;
          if (zone == null) {
            return const Center(child: Text('Zone not found'));
          }
          return _buildDetail(context, zone, theme, dateFormat);
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, EmissionZone zone,
      ThemeData theme, DateFormat dateFormat) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      zone.zoneType.contains('ZERO')
                          ? Icons.eco
                          : Icons.shield,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.name,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${zone.city}, ${zone.country}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Chip(
                  label: Text(
                    zone.zoneType.contains('ZERO')
                        ? 'Zero Emission Zone'
                        : 'Environmental Zone',
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zone Information',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                if (zone.activeFrom != null)
                  _infoRow(
                      'Active From', dateFormat.format(zone.activeFrom!)),
                if (zone.activeTo != null)
                  _infoRow('Active To', dateFormat.format(zone.activeTo!)),
                if (zone.activeDays != null)
                  _infoRow('Active Days', zone.activeDays!),
                if (zone.minimumEuroLevel != null)
                  _infoRow('Minimum Euro Class',
                      'Euro ${zone.minimumEuroLevel}'),
                if (zone.allowedFuelTypes != null &&
                    zone.allowedFuelTypes!.isNotEmpty)
                  _infoRow('Allowed Fuel Types',
                      zone.allowedFuelTypes!.join(', ')),
                if (zone.allowedVehicleTypes != null &&
                    zone.allowedVehicleTypes!.isNotEmpty)
                  _infoRow('Allowed Vehicle Types',
                      zone.allowedVehicleTypes!.join(', ')),
                if (zone.restrictions != null)
                  _infoRow('Restrictions', zone.restrictions!),
                if (zone.officialSource != null)
                  _infoRow('Official Source', zone.officialSource!),
                if (zone.lastVerifiedAt != null)
                  _infoRow('Last Verified',
                      dateFormat.format(zone.lastVerifiedAt!)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: theme.colorScheme.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: theme.colorScheme.onTertiaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informational result. Always verify official regulations.',
                    style: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
