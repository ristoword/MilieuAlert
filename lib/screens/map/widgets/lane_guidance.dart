import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../models/navigation_models.dart';

/// OSRM lane row: one arrow per real lane, valid lanes lit, others dim.
/// Hidden when the step has no intersection.lanes.
class LaneGuidanceRow extends StatelessWidget {
  const LaneGuidanceRow({
    super.key,
    required this.lanes,
    this.compact = false,
  });

  final List<NavLane> lanes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (lanes.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lit = isDark ? Colors.white : MapsColors.ink;
    final dim = (isDark ? Colors.white : MapsColors.ink).withValues(alpha: 0.22);
    final hasValid = lanes.any((l) => l.valid);
    final h = compact ? 28.0 : 34.0;
    final w = compact ? 18.0 : 22.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < lanes.length; i++) ...[
              if (i > 0) SizedBox(width: compact ? 4 : 6),
              SizedBox(
                width: w,
                height: h,
                child: CustomPaint(
                  painter: _LaneArrowPainter(
                    indications: lanes[i].indications,
                    color: (!hasValid || lanes[i].valid) ? lit : dim,
                    emphasis: !hasValid || lanes[i].valid,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LaneArrowPainter extends CustomPainter {
  _LaneArrowPainter({
    required this.indications,
    required this.color,
    required this.emphasis,
  });

  final List<String> indications;
  final Color color;
  final bool emphasis;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = emphasis ? 3.2 : 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final dirs = indications.isEmpty ? const ['straight'] : indications;
    for (final dir in dirs) {
      _paintIndication(canvas, size, dir, paint);
    }
  }

  void _paintIndication(Canvas canvas, Size size, String raw, Paint paint) {
    final dir = raw.toLowerCase().trim();
    if (dir.contains('uturn') || dir.contains('u-turn')) {
      _paintUturn(canvas, size, paint, dir.contains('right'));
      return;
    }

    final cx = size.width / 2;
    final bottom = size.height - 1.5;
    final top = 7.0;
    final angle = _angleFor(dir);
    canvas.save();
    canvas.translate(cx, bottom);
    canvas.rotate(angle);
    canvas.translate(-cx, -bottom);

    final path = Path()
      ..moveTo(cx, bottom)
      ..lineTo(cx, top);
    canvas.drawPath(path, paint);

    final head = Path()
      ..moveTo(cx - 6.2, top + 8.5)
      ..lineTo(cx, top)
      ..lineTo(cx + 6.2, top + 8.5);
    canvas.drawPath(head, paint);
    canvas.restore();
  }

  void _paintUturn(Canvas canvas, Size size, Paint paint, bool right) {
    final cx = size.width / 2;
    final bottom = size.height - 1.5;
    final midY = size.height * 0.42;
    final side = right ? 1.0 : -1.0;
    final x2 = cx + side * (size.width * 0.42);
    final path = Path()
      ..moveTo(cx, bottom)
      ..lineTo(cx, midY)
      ..arcToPoint(
        Offset(x2, midY),
        radius: Radius.circular((x2 - cx).abs() / 2),
        clockwise: right,
      )
      ..lineTo(x2, bottom - 6);
    canvas.drawPath(path, paint);
    final head = Path()
      ..moveTo(x2 - side * 5.5, bottom - 13)
      ..lineTo(x2, bottom - 5)
      ..lineTo(x2 + side * 5.5, bottom - 13);
    canvas.drawPath(head, paint);
  }

  double _angleFor(String dir) {
    if (dir.contains('sharp left')) return -math.pi * 0.48;
    if (dir.contains('sharp right')) return math.pi * 0.48;
    if (dir.contains('slight left')) return -math.pi * 0.16;
    if (dir.contains('slight right')) return math.pi * 0.16;
    if (dir.contains('left')) return -math.pi * 0.32;
    if (dir.contains('right')) return math.pi * 0.32;
    return 0;
  }

  @override
  bool shouldRepaint(covariant _LaneArrowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.emphasis != emphasis ||
        oldDelegate.indications.join() != indications.join();
  }
}
