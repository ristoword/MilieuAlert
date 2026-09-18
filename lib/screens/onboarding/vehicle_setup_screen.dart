import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/widgets/install_app_button.dart';
import '../../l10n/l10n_ext.dart';

class VehicleSetupScreen extends ConsumerStatefulWidget {
  const VehicleSetupScreen({super.key});

  @override
  ConsumerState<VehicleSetupScreen> createState() => _VehicleSetupScreenState();
}

class _VehicleSetupScreenState extends ConsumerState<VehicleSetupScreen> {
  VehicleType _vehicleType = VehicleType.car;
  FuelType _fuelType = FuelType.diesel;
  EuroClass _euroClass = EuroClass.euro4;
  final _licensePlateController = TextEditingController();
  String _country = 'NL';
  bool _saving = false;

  static const _countries = [
    ('NL', 'Netherlands 🇳🇱'),
    ('BE', 'Belgium 🇧🇪'),
    ('DE', 'Germany 🇩🇪'),
    ('FR', 'France 🇫🇷'),
    ('IT', 'Italy 🇮🇹'),
    ('LU', 'Luxembourg 🇱🇺'),
    ('AT', 'Austria 🇦🇹'),
    ('CH', 'Switzerland 🇨🇭'),
    ('GB', 'United Kingdom 🇬🇧'),
    ('ES', 'Spain 🇪🇸'),
    ('PT', 'Portugal 🇵🇹'),
    ('DK', 'Denmark 🇩🇰'),
    ('SE', 'Sweden 🇸🇪'),
    ('NO', 'Norway 🇳🇴'),
    ('PL', 'Poland 🇵🇱'),
    ('CZ', 'Czech Republic 🇨🇿'),
  ];

  @override
  void dispose() {
    _licensePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = l10nOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingVehicleTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/language'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.vehicleDescription,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.vehicleDescriptionSubtext,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _sectionLabel(l10n.vehicleType),
            DropdownButtonFormField<VehicleType>(
              initialValue: _vehicleType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: VehicleType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(localizedVehicleType(l10n, t)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _vehicleType = v);
              },
            ),
            const SizedBox(height: 16),
            _sectionLabel(l10n.fuelType),
            DropdownButtonFormField<FuelType>(
              initialValue: _fuelType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_gas_station),
              ),
              items: FuelType.values
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(localizedFuelType(l10n, f)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _fuelType = v);
              },
            ),
            const SizedBox(height: 16),
            _sectionLabel(l10n.euroClass),
            DropdownButtonFormField<EuroClass>(
              initialValue: _euroClass,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.eco),
              ),
              items: EuroClass.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.label),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _euroClass = v);
              },
            ),
            const SizedBox(height: 16),
            _sectionLabel(l10n.licensePlate),
            TextFormField(
              controller: _licensePlateController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.licensePlateHint,
                prefixIcon: const Icon(Icons.pin),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            _sectionLabel(l10n.country),
            DropdownButtonFormField<String>(
              initialValue: _country,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              items: _countries
                  .map((c) => DropdownMenuItem(
                        value: c.$1,
                        child: Text(c.$2),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _country = v);
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.saveAndContinue,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: InstallAppButton()),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Future<void> _saveVehicle() async {
    if (_saving) return;
    setState(() => _saving = true);

    final vehicle = Vehicle(
      type: _vehicleType,
      fuelType: _fuelType,
      euroClass: _euroClass,
      licensePlate: _licensePlateController.text.trim().isNotEmpty
          ? _licensePlateController.text.trim()
          : null,
      country: _country,
    );

    try {
      await ref
          .read(vehicleProvider.notifier)
          .saveVehicle(vehicle)
          .timeout(const Duration(seconds: 8));
    } catch (e, st) {
      debugPrint('Vehicle save failed, continuing onboarding: $e\n$st');
    }

    try {
      await ref.read(onboardingCompleteProvider.notifier).complete();
    } catch (e, st) {
      debugPrint('Failed to persist onboarding flag: $e\n$st');
    }

    if (!mounted) return;
    setState(() => _saving = false);
    context.go('/map');
  }
}
