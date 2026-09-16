import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../models/navigation_models.dart';
import '../../../models/poi_category.dart';

class LocationPuck extends StatelessWidget {
  const LocationPuck({super.key, this.heading});

  final double? heading;

  @override
  Widget build(BuildContext context) {
    final deg = heading;
    final rotate = deg != null && deg >= 0 && deg <= 360;
    final puck = SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (rotate)
            Positioned(
              top: 0,
              child: CustomPaint(
                size: const Size(14, 10),
                painter: _PuckConePainter(),
              ),
            ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MapsColors.route,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: MapsColors.route.withValues(alpha: 0.45),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (!rotate) return puck;
    return Transform.rotate(
      angle: deg * math.pi / 180,
      child: puck,
    );
  }
}

class _PuckConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = MapsColors.route.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CameraPin extends StatelessWidget {
  const CameraPin({super.key, this.community = false});

  final bool community;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: community ? const Color(0xFFFF3B30) : const Color(0xFFFF9F0A),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            community ? Icons.videocam_outlined : Icons.videocam,
            color: Colors.white,
            size: 16,
          ),
        ),
        if (community)
          const Positioned(
            right: -3,
            bottom: -3,
            child: CircleAvatar(
              radius: 7,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 10, color: Color(0xFFFF3B30)),
            ),
          ),
      ],
    );
  }
}

class HazardPin extends StatelessWidget {
  const HazardPin({
    super.key,
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}

class PoiPin extends StatelessWidget {
  const PoiPin({super.key, required this.hit});

  final PlaceHit hit;

  @override
  Widget build(BuildContext context) {
    final cat = poiCategoryById(hit.category);
    final color = hit.inLez ? MapsColors.lezOnRouteBorder : MapsColors.route;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(
            cat?.icon ?? Icons.place_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        if (hit.inLez)
          const Positioned(
            right: -2,
            top: -2,
            child: Icon(
              Icons.shield,
              size: 12,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
