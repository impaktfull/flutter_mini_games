import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/code/game/model/code_peg.dart';

/// Draws a [CodePeg] as its own shape, so pegs can be told apart without color
class CodePegShape extends StatelessWidget {
  final CodePeg peg;
  final Color color;

  const CodePegShape({
    required this.peg,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: peg.label,
      child: CustomPaint(
        painter: _CodePegPainter(peg: peg, color: color),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CodePegPainter extends CustomPainter {
  final CodePeg peg;
  final Color color;

  const _CodePegPainter({
    required this.peg,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final side = min(size.width, size.height);
    final center = size.center(Offset.zero);
    final radius = side / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    switch (peg) {
      case CodePeg.circle:
        canvas.drawCircle(center, radius * 0.92, paint);
      case CodePeg.square:
        final rect = Rect.fromCenter(center: center, width: side * 0.8, height: side * 0.8);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(side * 0.1)), paint);
      case CodePeg.triangle:
        canvas.drawPath(_polygon(center.translate(0, radius * 0.16), radius * 1.02, 3, -pi / 2), paint);
      case CodePeg.diamond:
        canvas.drawPath(_polygon(center, radius, 4, -pi / 2, xScale: 0.78), paint);
      case CodePeg.star:
        canvas.drawPath(_star(center.translate(0, radius * 0.06), radius * 1.02, radius * 0.45), paint);
      case CodePeg.hexagon:
        canvas.drawPath(_polygon(center, radius * 0.95, 6, 0), paint);
    }
  }

  static Path _polygon(Offset center, double radius, int sides, double startAngle, {double xScale = 1}) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = startAngle + 2 * pi * i / sides;
      final point = Offset(center.dx + cos(angle) * radius * xScale, center.dy + sin(angle) * radius);
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  static Path _star(Offset center, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -pi / 2 + pi * i / 5;
      final point = Offset(center.dx + cos(angle) * radius, center.dy + sin(angle) * radius);
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_CodePegPainter oldDelegate) => oldDelegate.peg != peg || oldDelegate.color != color;
}
