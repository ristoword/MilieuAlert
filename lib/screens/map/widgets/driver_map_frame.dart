import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Apple Maps–like driver tilt on top of flutter_map (no MapLibre).
Matrix4 driverTiltMatrix({double degrees = 48}) {
  return Matrix4.identity()
    ..setEntry(3, 2, 0.00115)
    ..rotateX(degrees * math.pi / 180)
    ..scaleByDouble(1.38, 1.38, 1.38, 1);
}

class DriverMapFrame extends StatelessWidget {
  const DriverMapFrame({
    super.key,
    required this.tilted,
    required this.child,
  });

  final bool tilted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!tilted) return child;
    return ClipRect(
      child: Transform(
        alignment: const Alignment(0, 0.55),
        transform: driverTiltMatrix(),
        filterQuality: FilterQuality.low,
        child: child,
      ),
    );
  }
}
