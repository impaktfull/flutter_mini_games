import 'dart:math';

import 'package:flutter/material.dart';

/// An open hand seen from above, fingers pointing down, drawn with solid shapes:
/// first every shape thick in [outlineColor], then every shape filled with [color], so the
/// fingers are separated by the outline without any alpha
class SlapHand extends StatelessWidget {
  /// Height of the hand relative to its width
  static const aspectRatio = 1.3;

  final double width;
  final Color color;
  final Color outlineColor;
  final double outlineWidth;

  const SlapHand({
    required this.width,
    required this.color,
    required this.outlineColor,
    required this.outlineWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * aspectRatio),
      painter: _SlapHandPainter(color: color, outlineColor: outlineColor, outlineWidth: outlineWidth),
    );
  }
}

class _SlapHandPainter extends CustomPainter {
  final Color color;
  final Color outlineColor;
  final double outlineWidth;

  const _SlapHandPainter({
    required this.color,
    required this.outlineColor,
    required this.outlineWidth,
  });

  /// Shapes of the hand in a box of 1 wide and [SlapHand.aspectRatio] high
  static List<Path> _shapes() {
    Path capsule(Offset from, Offset to, double width) {
      final direction = to - from;
      final length = direction.distance;
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(-width / 2, -width / 2, width, length + width), Radius.circular(width / 2));
      final matrix = Matrix4.translationValues(from.dx, from.dy, 0)..rotateZ(atan2(direction.dy, direction.dx) - pi / 2);
      return (Path()..addRRect(rect)).transform(matrix.storage);
    }

    return [
      // Thumb
      capsule(const Offset(0.3, 0.38), const Offset(0.1, 0.78), 0.17),
      // Fingers: index, middle, ring, little
      capsule(const Offset(0.31, 0.55), const Offset(0.29, 1.1), 0.15),
      capsule(const Offset(0.48, 0.55), const Offset(0.48, 1.2), 0.155),
      capsule(const Offset(0.65, 0.55), const Offset(0.67, 1.14), 0.15),
      capsule(const Offset(0.82, 0.5), const Offset(0.87, 0.98), 0.135),
      // Palm
      Path()..addRRect(
        RRect.fromLTRBAndCorners(
          0.22,
          0,
          0.92,
          0.72,
          topLeft: const Radius.circular(0.3),
          topRight: const Radius.circular(0.3),
          bottomLeft: const Radius.circular(0.14),
          bottomRight: const Radius.circular(0.14),
        ),
      ),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width;
    canvas
      ..save()
      ..scale(scale);
    final shapes = _shapes();
    final outline = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = outlineWidth * 2 / scale;
    final fill = Paint()..color = color;
    for (final shape in shapes) {
      canvas.drawPath(shape, outline);
    }
    for (final shape in shapes) {
      canvas.drawPath(shape, fill);
    }
    // Knuckle creases
    final crease = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = outlineWidth / scale;
    for (final x in [0.31, 0.48, 0.65]) {
      canvas.drawLine(Offset(x, 0.8), Offset(x, 0.88), crease);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SlapHandPainter oldDelegate) => oldDelegate.color != color || oldDelegate.outlineColor != outlineColor || oldDelegate.outlineWidth != outlineWidth;
}
