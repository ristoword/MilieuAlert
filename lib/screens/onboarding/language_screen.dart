import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_provider.dart';
import '../../core/widgets/install_app_button.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const _languages = [
    _LanguageOption('en', 'English', '🇬🇧'),
    _LanguageOption('nl', 'Nederlands', '🇳🇱'),
    _LanguageOption('de', 'Deutsch', '🇩🇪'),
    _LanguageOption('fr', 'Français', '🇫🇷'),
    _LanguageOption('it', 'Italiano', '🇮🇹'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Icon(
                Icons.language,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Select Language',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferred language',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected =
                        currentLocale.languageCode == lang.code;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        leading: Text(
                          lang.flag,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          lang.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: theme.colorScheme.primary)
                            : null,
                        onTap: () {
                          ref
                              .read(localeProvider.notifier)
                              .setLocale(lang.code);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const InstallAppButton(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/onboarding/vehicle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Next',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String name;
  final String flag;

  const _LanguageOption(this.code, this.name, this.flag);
}
