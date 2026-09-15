import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/map/map_screen.dart';
import '../screens/onboarding/language_screen.dart';
import '../screens/onboarding/vehicle_setup_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/zone_detail/zone_detail_screen.dart';
import '../providers/settings_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: onboardingComplete ? '/map' : '/onboarding/language',
    routes: [
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
});
