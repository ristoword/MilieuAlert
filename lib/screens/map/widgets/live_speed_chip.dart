import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';

/// Compact GPS speed + legal maxspeed. Lives in the turn/ETA chrome,
/// never as a map-covering banner.
class LiveSpeedChip extends StatelessWidget {
  const LiveSpeedChip({
    super.key,
    required this.speedKmh,
    required this.limitKmh,
    this.speeding = false,
    this.compact = false,
  });

  final int? speedKmh;
  final int? limitKmh;
  final bool speeding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? Colors.white : MapsColors.ink;
    final speedColor = speeding ? MapsColors.endRed : ink;
    final speedText = speedKmh == null ? '—' : '$speedKmh';

    final speedCol = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          speedText,
          style: GoogleFonts.inter(
            fontSize: compact ? 22 : 26,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: -0.8,
            color: speedColor,
          ),
        ),
        Text(
          'km/h',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: speeding
                ? MapsColors.endRed
                : (isDark
                    ? Colors.white.withValues(alpha: 0.55)
                    : MapsColors.inkMuted),
          ),
        ),
      ],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        speedCol,
        const SizedBox(width: 8),
        _LimitRoundel(limitKmh: limitKmh, compact: compact),
      ],
    );
  }
}

class _LimitRoundel extends StatelessWidget {
  const _LimitRoundel({required this.limitKmh, required this.compact});

  final int? limitKmh;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 36.0 : 42.0;
    final has = limitKmh != null && limitKmh! > 0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE53935), width: compact ? 3.2 : 3.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        has ? '${limitKmh!}' : '—',
        style: GoogleFonts.inter(
          fontSize: has && limitKmh! >= 100
              ? (compact ? 12 : 13)
              : (compact ? 15 : 16),
          fontWeight: FontWeight.w800,
          height: 1,
          color: const Color(0xFF1C1C1E),
        ),
      ),
    );
  }
}
