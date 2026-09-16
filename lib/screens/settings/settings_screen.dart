import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/widgets/main_bottom_nav.dart';
import '../../models/vehicle.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../core/widgets/install_app_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final alertDistance = ref.watch(alertDistanceProvider);
    final vehicleAsync = ref.watch(vehicleProvider);

    return Scaffold(
      bottomNavigationBar: const MainBottomNav(),
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/map'),
        ),
      ),
      body: ListView(
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
                      Icon(Icons.language, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Language',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: locale.languageCode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'en', child: Text('🇬🇧 English')),
                      DropdownMenuItem(
                          value: 'nl', child: Text('🇳🇱 Nederlands')),
                      DropdownMenuItem(
                          value: 'de', child: Text('🇩🇪 Deutsch')),
                      DropdownMenuItem(
                          value: 'fr', child: Text('🇫🇷 Français')),
                      DropdownMenuItem(
                          value: 'it', child: Text('🇮🇹 Italiano')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(localeProvider.notifier).setLocale(v);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Alert Distance',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: alertDistance,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: AppConstants.alertDistances
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(
                                  d >= 1000 ? '${d ~/ 1000} km' : '$d m'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        ref
                            .read(alertDistanceProvider.notifier)
                            .setDistance(v);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.directions_car,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Vehicle Information',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  vehicleAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (vehicle) {
                      if (vehicle == null) {
                        return const Text('No vehicle configured');
                      }
                      return Column(
                        children: [
                          _vehicleInfoRow(
                              'Type', _vehicleTypeLabel(vehicle.type)),
                          _vehicleInfoRow('Fuel', vehicle.fuelType.label),
                          _vehicleInfoRow(
                              'Euro Class', vehicle.euroClass.label),
                          if (vehicle.licensePlate != null)
                            _vehicleInfoRow(
                                'License Plate', vehicle.licensePlate!),
                          if (vehicle.country != null)
                            _vehicleInfoRow('Country', vehicle.country!),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/onboarding/vehicle'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Vehicle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Install on this PC',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add MilieuAlert as an app on your desktop — no store or SDK required.',
                  ),
                  SizedBox(height: 12),
                  InstallAppButton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/auth');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icon/logo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'MilieuAlert v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informational result. Always verify official regulations.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _vehicleTypeLabel(VehicleType type) {
    switch (type) {
      case VehicleType.car:
        return 'Car';
      case VehicleType.van:
        return 'Van';
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.camper:
        return 'Camper';
      case VehicleType.motorcycle:
        return 'Motorcycle';
    }
  }
}
