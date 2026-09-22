import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/widgets/main_bottom_nav.dart';
import '../../l10n/l10n_ext.dart';
import '../../models/vehicle.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/voice_guidance_provider.dart';
import '../../core/widgets/install_app_button.dart';
import '../../core/widgets/paywall.dart';
import '../../providers/entitlement_provider.dart';
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

  String _language = 'it';
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
          _language = supported.contains(lang) ? lang : 'it';
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

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(url)),
      );
    }
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

    final l10n = l10nOf(context);
    final err = ref.read(authProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? l10n.personalDataSaved
              : (err ?? l10n.savedLocallyServerFailed),
        ),
        backgroundColor: ok ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = l10nOf(context);
    final alertDistance = ref.watch(alertDistanceProvider);
    final auth = ref.watch(authProvider);
    final countryValue = _countries.any((c) => c.$1 == _country) ? _country : 'NL';

    return Scaffold(
      bottomNavigationBar: const MainBottomNav(),
      appBar: AppBar(
        title: Text(l10n.settings),
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
              PaywallSettingsCard(),
              const SizedBox(height: 12),
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
                            l10n.personalData,
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
                        decoration: InputDecoration(
                          labelText: l10n.name,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.enterName
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        readOnly: false,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.isEmpty || !value.contains('@')) {
                            return l10n.enterValidEmail;
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
                          labelText: l10n.newPasswordOptional,
                          hintText: l10n.leaveBlankPassword,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword ? l10n.show : l10n.hide,
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
                            return l10n.atLeast8Chars;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey('country-$countryValue'),
                        initialValue: countryValue,
                        decoration: InputDecoration(
                          labelText: l10n.country,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.flag_outlined),
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
                            l10n.language,
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
                            l10n.navVoice,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.woman_outlined),
                        title: Text(l10n.voiceFemale),
                        trailing: IconButton(
                          icon: const Icon(Icons.volume_up_outlined),
                          tooltip: l10n.navVoice,
                          onPressed: () =>
                              ref.read(voiceGuidanceProvider).preview(),
                        ),
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
                            l10n.alertDistance,
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
                            l10n.yourCar,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<VehicleType>(
                        key: ValueKey('vtype-${_vehicleType.name}'),
                        initialValue: _vehicleType,
                        decoration: InputDecoration(
                          labelText: l10n.type,
                          border: const OutlineInputBorder(),
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<FuelType>(
                        key: ValueKey('fuel-${_fuelType.name}'),
                        initialValue: _fuelType,
                        decoration: InputDecoration(
                          labelText: l10n.fuel,
                          border: const OutlineInputBorder(),
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<EuroClass>(
                        key: ValueKey('euro-${_euroClass.name}'),
                        initialValue: _euroClass,
                        decoration: InputDecoration(
                          labelText: l10n.euroClass,
                          border: const OutlineInputBorder(),
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
                        decoration: InputDecoration(
                          labelText: l10n.licensePlate,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.pin_outlined),
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
                  label: Text(_saving ? l10n.saving : l10n.savePersonalData),
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
                  title: Text(l10n.aiAssistant),
                  subtitle: Text(l10n.aiAssistantSubtitle),
                  trailing: Icon(
                    ref.watch(entitlementProvider).fullAccess
                        ? Icons.chevron_right
                        : Icons.lock_outline,
                  ),
                  onTap: () {
                    if (ref.read(entitlementProvider).navigatorOnly) {
                      showPaywallSheet(context);
                      return;
                    }
                    showAiAssistSheet(context);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.installOnPc,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.installOnPcBody),
                      const SizedBox(height: 12),
                      const InstallAppButton(),
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
                  label: Text(l10n.signOut),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.aboutSection,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.notGovernmentDisclaimer,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.officialSourcesSection,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...AppConstants.officialLezSources.map(
                        (source) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(
                            Icons.open_in_new,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            source.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          subtitle: Text(
                            source.url,
                            style: theme.textTheme.labelSmall,
                          ),
                          onTap: () => _openExternalUrl(source.url),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.disclaimer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
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
                      l10n.appVersion('1.0.2'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

