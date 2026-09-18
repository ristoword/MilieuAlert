import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/theme.dart';
import '../../../services/geo_utils.dart';

/// Diameter of the wind-rose control.
const double kWindRoseSize = 52;

/// After a north-up peek during guidance, resume course-up.
const Duration kNorthUpPeekDuration = Duration(seconds: 6);

/// Radians to rotate the rose so N stays on true north while the map
/// is course-up (`mapRotationDeg` is flutter_map camera.rotation).
double windRoseAngleRad(double mapRotationDeg) =>
    -mapRotationDeg * math.pi / 180;

/// Classic stella dei venti: the rose rotates with the map so N stays on
/// true north while the road stays straight up on screen.
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
      if (headingDeltaDeg(_rotation, next) < 0.15 && mounted) return;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MapsGlass(
      radius: kWindRoseSize / 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: widget.headingUp
                ? widget.headingUpTooltip
                : widget.northUpTooltip,
            child: SizedBox(
              key: const ValueKey('map-wind-rose'),
              width: kWindRoseSize,
              height: kWindRoseSize,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Transform.rotate(
                  angle: windRoseAngleRad(_rotation),
                  child: CustomPaint(
                    painter: WindRosePainter(
                      headingUp: widget.headingUp,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 16-point compass rose. Petals are drawn with N up in local space; the
/// parent rotates the whole rose by `-map.rotation` so N tracks true north.
class WindRosePainter extends CustomPainter {
  WindRosePainter({
    required this.headingUp,
    this.isDark = false,
  });

  final bool headingUp;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    canvas.save();
    canvas.translate(c.dx, c.dy);

    if (headingUp) {
      canvas.drawCircle(
        Offset.zero,
        r,
        Paint()..color = MapsColors.route.withValues(alpha: 0.10),
      );
    }

    canvas.drawCircle(
      Offset.zero,
      r - 0.4,
      Paint()
        ..color = isDark
            ? Colors.white.withValues(alpha: 0.22)
            : const Color(0xFF3A3A3C).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    for (var i = 1; i < 16; i += 2) {
      _petal(canvas, r * 0.50, r * 0.055, i * 22.5, _halfDark, _halfLight);
    }
    for (var i = 2; i < 16; i += 4) {
      _petal(canvas, r * 0.70, r * 0.10, i * 22.5, _interDark, _interLight);
    }
    for (var i = 4; i < 16; i += 4) {
      _petal(canvas, r * 0.86, r * 0.145, i * 22.5, _cardDark, _cardLight);
    }
    _petal(canvas, r * 0.92, r * 0.16, 0, _northDark, _northLight);

    canvas.drawCircle(
      Offset.zero,
      r * 0.12,
      Paint()..color = isDark ? const Color(0xFF2C2C2E) : Colors.white,
    );
    canvas.drawCircle(
      Offset.zero,
      r * 0.12,
      Paint()
        ..color = MapsColors.ink.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
    canvas.drawCircle(
      Offset.zero,
      r * 0.035,
      Paint()..color = MapsColors.endRed,
    );

    _letter(canvas, 'N', Offset(0, -r * 0.58), MapsColors.endRed, r * 0.42);
    _letter(canvas, 'E', Offset(r * 0.56, 0), _labelColor, r * 0.34);
    _letter(canvas, 'S', Offset(0, r * 0.58), _labelColor, r * 0.34);
    _letter(canvas, 'W', Offset(-r * 0.56, 0), _labelColor, r * 0.34);

    canvas.restore();
  }

  Color get _labelColor =>
      isDark ? const Color(0xFFF2F2F7) : MapsColors.ink;
  Color get _cardDark =>
      isDark ? const Color(0xFF8E8E93) : const Color(0xFF2C2C2E);
  Color get _cardLight =>
      isDark ? const Color(0xFFD1D1D6) : const Color(0xFFD1D1D6);
  Color get _interDark =>
      isDark ? const Color(0xFF636366) : const Color(0xFF636366);
  Color get _interLight =>
      isDark ? const Color(0xFFC7C7CC) : const Color(0xFFE5E5EA);
  Color get _halfDark =>
      isDark ? const Color(0xFF48484A) : const Color(0xFF8E8E93);
  Color get _halfLight =>
      isDark ? const Color(0xFFAEAEB2) : const Color(0xFFF2F2F7);
  static const _northDark = Color(0xFFB71C1C);
  static const _northLight = MapsColors.endRed;

  void _petal(
    Canvas canvas,
    double length,
    double halfW,
    double deg,
    Color left,
    Color right,
  ) {
    canvas.save();
    canvas.rotate(deg * math.pi / 180);
    final l = Path()
      ..moveTo(0, 0)
      ..lineTo(-halfW, -length * 0.34)
      ..lineTo(0, -length)
      ..close();
    final ri = Path()
      ..moveTo(0, 0)
      ..lineTo(halfW, -length * 0.34)
      ..lineTo(0, -length)
      ..close();
    canvas.drawPath(l, Paint()..color = left);
    canvas.drawPath(ri, Paint()..color = right);
    canvas.restore();
  }

  void _letter(Canvas canvas, String text, Offset at, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant WindRosePainter oldDelegate) =>
      oldDelegate.headingUp != headingUp || oldDelegate.isDark != isDark;
}
