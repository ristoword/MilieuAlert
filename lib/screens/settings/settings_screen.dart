import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/widgets/main_bottom_nav.dart';
import '../../models/vehicle.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/voice_guidance_provider.dart';
import '../../core/widgets/install_app_button.dart';
import '../map/widgets/ai_assist_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _plateCtrl;

  String _language = 'en';
  String _country = 'NL';
  VehicleType _vehicleType = VehicleType.car;
  FuelType _fuelType = FuelType.diesel;
  EuroClass _euroClass = EuroClass.euro4;
  bool _obscurePassword = true;
  bool _saving = false;
  bool _hydrated = false;

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
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _nameCtrl = TextEditingController(text: auth.displayName ?? '');
    _emailCtrl = TextEditingController(text: auth.email ?? '');
    _passwordCtrl = TextEditingController();
    _plateCtrl = TextEditingController();
    _language = ref.read(localeProvider).languageCode;
    _country = auth.country ?? 'NL';
    _applyVehicle(ref.read(vehicleProvider).valueOrNull);
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    await ref.read(authProvider.notifier).refreshProfile();
    if (!mounted) return;
    final auth = ref.read(authProvider);
    final vehicle = ref.read(vehicleProvider).valueOrNull;
    setState(() {
      if (!_hydrated) {
        if ((auth.displayName ?? '').isNotEmpty) {
          _nameCtrl.text = auth.displayName!;
        }
        if ((auth.email ?? '').isNotEmpty) {
          _emailCtrl.text = auth.email!;
        }
        if (auth.country != null && auth.country!.isNotEmpty) {
          _country = _normalizeCountry(auth.country!);
        }
        if (auth.preferredLanguage != null &&
            auth.preferredLanguage!.isNotEmpty) {
          const supported = ['en', 'nl', 'de', 'fr', 'it'];
          final lang = auth.preferredLanguage!.toLowerCase();
          _language = supported.contains(lang) ? lang : 'en';
        }
        _applyVehicle(vehicle);
        _hydrated = true;
      }
    });
  }

  void _applyVehicle(Vehicle? vehicle) {
    if (vehicle == null) return;
    _vehicleType = vehicle.type;
    _fuelType = vehicle.fuelType;
    _euroClass = vehicle.euroClass;
    if (vehicle.licensePlate != null) {
      _plateCtrl.text = vehicle.licensePlate!;
    }
    if (vehicle.country != null && vehicle.country!.isNotEmpty) {
      _country = _normalizeCountry(vehicle.country!);
    }
  }

  String _normalizeCountry(String raw) {
    final code = raw.trim().toUpperCase();
    final match = _countries.where((c) => c.$1 == code);
    return match.isEmpty ? 'NL' : match.first.$1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final vehicle = Vehicle(
      id: ref.read(vehicleProvider).valueOrNull?.id,
      type: _vehicleType,
      fuelType: _fuelType,
      euroClass: _euroClass,
      licensePlate:
          _plateCtrl.text.trim().isEmpty ? null : _plateCtrl.text.trim(),
      country: _country,
    );

    await ref.read(vehicleProvider.notifier).saveVehicle(vehicle);
    await ref.read(localeProvider.notifier).setLocale(_language);

    final ok = await ref.read(authProvider.notifier).updateProfile(
          displayName: _nameCtrl.text,
          email: _emailCtrl.text,
          country: _country,
          preferredLanguage: _language,
          password: _passwordCtrl.text,
          vehicle: vehicle.toJson(),
        );

    if (!mounted) return;
    setState(() => _saving = false);
    _passwordCtrl.clear();

    final err = ref.read(authProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Personal data saved'
              : (err ?? 'Saved locally. Could not update the server.'),
        ),
        backgroundColor: ok ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertDistance = ref.watch(alertDistanceProvider);
    final auth = ref.watch(authProvider);
    final countryValue = _countries.any((c) => c.$1 == _country) ? _country : 'NL';

    return Scaffold(
      bottomNavigationBar: const MainBottomNav(),
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/map'),
        ),
      ),
      body: AutofillGroup(
        child: Form(
          key: _formKey,
          child: ListView(
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
                          Icon(Icons.person, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Personal data',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameCtrl,
                        readOnly: false,
                        obscureText: false,
                        enableSuggestions: true,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        readOnly: false,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty || !value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        readOnly: false,
                        obscureText: _obscurePassword,
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: InputDecoration(
                          labelText: 'New password (optional)',
                          hintText: 'Leave blank to keep current',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword ? 'Show' : 'Hide',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          if (v.length < 8) {
                            return 'At least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey('country-$countryValue'),
                        initialValue: countryValue,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: _countries
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.$1,
                                child: Text(c.$2),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _country = v);
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
                        key: ValueKey('lang-$_language'),
                        initialValue: _language,
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
                          if (v != null) setState(() => _language = v);
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
                          Icon(Icons.record_voice_over,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Voce navigazione',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<NavVoiceGender>(
                        segments: const [
                          ButtonSegment(
                            value: NavVoiceGender.male,
                            label: Text('Maschile'),
                            icon: Icon(Icons.man_outlined),
                          ),
                          ButtonSegment(
                            value: NavVoiceGender.female,
                            label: Text('Femminile'),
                            icon: Icon(Icons.woman_outlined),
                          ),
                        ],
                        selected: {ref.watch(navVoiceProvider)},
                        onSelectionChanged: (selected) async {
                          if (selected.isEmpty) return;
                          await ref
                              .read(navVoiceProvider.notifier)
                              .setGender(selected.first);
                          await ref.read(voiceGuidanceProvider).preview();
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
                        key: ValueKey('alert-$alertDistance'),
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
                            'Your car',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<VehicleType>(
                        key: ValueKey('vtype-${_vehicleType.name}'),
                        initialValue: _vehicleType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: VehicleType.values
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(_vehicleTypeLabel(t)),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _vehicleType = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<FuelType>(
                        key: ValueKey('fuel-${_fuelType.name}'),
                        initialValue: _fuelType,
                        decoration: const InputDecoration(
                          labelText: 'Fuel',
                          border: OutlineInputBorder(),
                        ),
                        items: FuelType.values
                            .map((f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(f.label),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _fuelType = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<EuroClass>(
                        key: ValueKey('euro-${_euroClass.name}'),
                        initialValue: _euroClass,
                        decoration: const InputDecoration(
                          labelText: 'Euro class',
                          border: OutlineInputBorder(),
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _plateCtrl,
                        readOnly: false,
                        obscureText: false,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'License plate (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving || auth.isLoading ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving…' : 'Save personal data'),
                ),
              ),
              if (auth.errorMessage != null && !_saving) ...[
                const SizedBox(height: 8),
                Text(
                  auth.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(Icons.auto_awesome,
                      color: theme.colorScheme.primary),
                  title: const Text('AI assistant'),
                  subtitle: const Text('Ask about zones, cameras and the route'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAiAssistSheet(context),
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
}
