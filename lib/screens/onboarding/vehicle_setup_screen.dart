import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/settings_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Setup'),
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
              'Tell us about your vehicle',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This information helps determine if your vehicle is allowed in emission zones.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _sectionLabel('Vehicle Type'),
            DropdownButtonFormField<VehicleType>(
              initialValue: _vehicleType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: VehicleType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(_vehicleTypeLabel(t)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _vehicleType = v!),
            ),
            const SizedBox(height: 16),
            _sectionLabel('Fuel Type'),
            DropdownButtonFormField<FuelType>(
              initialValue: _fuelType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_gas_station),
              ),
              items: FuelType.values
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.label),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _fuelType = v!),
            ),
            const SizedBox(height: 16),
            _sectionLabel('Euro Class'),
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
              onChanged: (v) => setState(() => _euroClass = v!),
            ),
            const SizedBox(height: 16),
            _sectionLabel('License Plate (optional)'),
            TextFormField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. AB-123-CD',
                prefixIcon: Icon(Icons.pin),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            _sectionLabel('Country of Registration'),
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
              onChanged: (v) => setState(() => _country = v!),
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
                    : const Text(
                        'Save & Continue',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
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

  Future<void> _saveVehicle() async {
    setState(() => _saving = true);
    try {
      final vehicle = Vehicle(
        type: _vehicleType,
        fuelType: _fuelType,
        euroClass: _euroClass,
        licensePlate: _licensePlateController.text.isNotEmpty
            ? _licensePlateController.text
            : null,
        country: _country,
      );

      await ref.read(vehicleProvider.notifier).saveVehicle(vehicle);

      final prefs = ref.read(sharedPrefsProvider);
      await prefs.setBool('onboardingComplete', true);

      if (mounted) {
        context.go('/map');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
