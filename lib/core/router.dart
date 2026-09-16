import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/onboarding/language_screen.dart';
import '../screens/onboarding/vehicle_setup_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/zone_detail/zone_detail_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  ref.listen<bool>(
    authProvider.select((s) => s.isAuthenticated),
    (_, __) => refresh.value++,
  );
  ref.listen<bool>(
    onboardingCompleteProvider,
    (_, __) => refresh.value++,
  );

  final router = GoRouter(
    initialLocation: '/auth',
    refreshListenable: refresh,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authProvider).isAuthenticated;
      final onboardingComplete = ref.read(onboardingCompleteProvider);
      final location = state.matchedLocation;
      final isOnAuthPage = location == '/auth';
      final isOnboarding = location.startsWith('/onboarding');

      if (!isAuthenticated && !isOnAuthPage) {
        return '/auth';
      }

      if (isAuthenticated && !onboardingComplete && !isOnboarding) {
        return '/onboarding/language';
      }

      if (isAuthenticated && onboardingComplete && (isOnAuthPage || isOnboarding)) {
        return '/map';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding/language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/onboarding/vehicle',
        builder: (context, state) => const VehicleSetupScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => MapScreen(
          openNavigation: state.uri.queryParameters['nav'] == '1',
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/zone/:id',
        builder: (context, state) {
          final zoneId = state.pathParameters['id']!;
          return ZoneDetailScreen(zoneId: zoneId);
        },
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });

  return router;
});
