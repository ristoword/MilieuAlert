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
      final isOnAuthPage = state.matchedLocation == '/auth';

      // Not authenticated → force to /auth
      if (!isAuthenticated && !isOnAuthPage) {
        return '/auth';
      }

      // Authenticated but on auth page → redirect away
      if (isAuthenticated && isOnAuthPage) {
        return onboardingComplete ? '/map' : '/onboarding/language';
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
        builder: (context, state) => const MapScreen(),
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
