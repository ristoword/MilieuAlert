import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/zone_status.dart';

class AlertBanner extends StatefulWidget {
  final ZoneProximity? proximity;

  const AlertBanner({
    super.key,
    this.proximity,
  });

  @override
  State<AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<AlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShow =
        widget.proximity != null && widget.proximity!.status != ZoneStatus.safe;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: shouldShow ? _buildBanner(context) : const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    LinearGradient borderGradient;
    Color glowColor;
    IconData icon;
    String message;
    String subtitle;

    switch (widget.proximity!.status) {
      case ZoneStatus.approaching:
        borderGradient = NeonColors.warningGradient;
        glowColor = NeonColors.orange;
        icon = Icons.warning_amber_rounded;
        final dist = widget.proximity!.distanceMeters?.toInt() ?? 0;
        message = 'ZONE APPROACHING';
        subtitle = '${widget.proximity!.zoneName} \u2014 ${dist}m away';
        break;
      case ZoneStatus.inside:
        if (widget.proximity!.isVehicleAllowed == false) {
          borderGradient = NeonColors.dangerGradient;
          glowColor = NeonColors.pink;
          icon = Icons.error_outline;
          message = 'VEHICLE NOT AUTHORIZED';
          subtitle = widget.proximity!.zoneName;
        } else {
          borderGradient = NeonColors.safeGradient;
          glowColor = NeonColors.neonGreen;
          icon = Icons.check_circle_outline;
          message = 'VEHICLE AUTHORIZED';
          subtitle = 'Inside ${widget.proximity!.zoneName}';
        }
        break;
      default:
        return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          key: ValueKey(
              'alert_${widget.proximity!.status}_${widget.proximity!.zoneId}'),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: borderGradient,
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? NeonColors.deepSpace.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: borderGradient,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: GoogleFonts.exo2(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: glowColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
