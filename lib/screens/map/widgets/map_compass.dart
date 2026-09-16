import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/theme.dart';
import '../../../services/geo_utils.dart';

/// Apple Maps–style compass: N stays on true north while the map rotates.
class MapCompassButton extends StatefulWidget {
  const MapCompassButton({
    super.key,
    required this.controller,
    required this.headingUp,
    required this.onTap,
    this.northUpTooltip = 'North up',
    this.headingUpTooltip = 'Heading up',
  });

  final MapController controller;
  final bool headingUp;
  final VoidCallback onTap;
  final String northUpTooltip;
  final String headingUpTooltip;

  @override
  State<MapCompassButton> createState() => _MapCompassButtonState();
}

class _MapCompassButtonState extends State<MapCompassButton> {
  StreamSubscription<MapEvent>? _sub;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _listen(widget.controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncRotation();
    });
  }

  @override
  void didUpdateWidget(MapCompassButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _sub?.cancel();
      _listen(widget.controller);
    }
    _syncRotation();
  }

  void _listen(MapController controller) {
    _sub = controller.mapEventStream.listen((_) => _syncRotation());
  }

  void _syncRotation() {
    try {
      final next = widget.controller.camera.rotation;
      if (headingDeltaDeg(_rotation, next) < 0.4 && mounted) return;
      if (!mounted) return;
      setState(() => _rotation = next);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapsGlass(
      radius: 22,
      child: IconButton(
        tooltip:
            widget.headingUp ? widget.headingUpTooltip : widget.northUpTooltip,
        onPressed: widget.onTap,
        visualDensity: VisualDensity.compact,
        icon: SizedBox(
          width: 22,
          height: 22,
          child: Transform.rotate(
            angle: -_rotation * math.pi / 180,
            child: CustomPaint(
              painter: _CompassPainter(headingUp: widget.headingUp),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.headingUp});

  final bool headingUp;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = headingUp
            ? MapsColors.route.withValues(alpha: 0.12)
            : Colors.transparent,
    );

    final north = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + 4.2, c.dy + 1)
      ..lineTo(c.dx, c.dy - 1.5)
      ..lineTo(c.dx - 4.2, c.dy + 1)
      ..close();
    final south = Path()
      ..moveTo(c.dx, c.dy + r)
      ..lineTo(c.dx + 4.2, c.dy - 1)
      ..lineTo(c.dx, c.dy + 1.5)
      ..lineTo(c.dx - 4.2, c.dy - 1)
      ..close();

    canvas.drawPath(south, Paint()..color = const Color(0xFFC7C7CC));
    canvas.drawPath(north, Paint()..color = MapsColors.endRed);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          color: MapsColors.ink,
          fontSize: 7,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - r + 1.5));
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.headingUp != headingUp;
}
