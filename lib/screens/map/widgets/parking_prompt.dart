import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../models/navigation_models.dart';
import '../../../providers/live_hud_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../services/parking_launcher.dart';

Future<void> launchEasyPark(BuildContext context) async {
  final ok = await openEasyPark();
  if (ok || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10nOf(context).parkingOpenError)),
  );
}

/// Shown near the destination: opens the official EasyPark app to pay for
/// street parking. No payment is handled by MilieuAlert.
class ParkingArrivalCard extends ConsumerWidget {
  const ParkingArrivalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navigationProvider);
    final live = ref.watch(liveHudProvider).snapshot.live;
    final show = shouldPromptParking(
      navigating: nav.navigating,
      isCar: nav.mode.isCar,
      remainingMeters: live?.remainingMeters,
    );
    if (!show) return const SizedBox.shrink();
    final l10n = l10nOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFF0A84FF),
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => launchEasyPark(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.local_parking_rounded,
                    color: Colors.white, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.parkingPayTitle,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        l10n.parkingPayHint,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.open_in_new_rounded,
                    color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
