import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/game/whack/game/model/whack_target.dart';
import 'package:flutter_mini_games/src/game/whack/style/whack_theme.dart';

/// One hole with the target that pops out of it.
///
/// Uses raw pointer events so every finger counts, also when several holes are tapped at once.
class WhackHole extends StatelessWidget {
  final int hole;
  final WhackTarget? target;

  /// How far [target] is out of the hole: 0 hidden, 1 fully up
  final double pop;
  final VoidCallback onTap;

  const WhackHole({
    required this.hole,
    required this.target,
    required this.pop,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WhackTheme.of(context);
    final target = this.target;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onTap(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.cell,
          borderRadius: BorderRadius.circular(theme.dimens.cellRadius),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _WhackHolePainter(
                colors: theme.colors,
                kind: target?.kind,
                isHit: target?.isHit ?? false,
                pop: pop,
              ),
            ),
            if (target != null && target.isHit)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    target.isDecoy ? '-1' : '+1',
                    style: target.isDecoy ? theme.textStyles.decoyHit : theme.textStyles.hit,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WhackHolePainter extends CustomPainter {
  final WhackColors colors;
  final WhackTargetKind? kind;
  final bool isHit;
  final double pop;

  _WhackHolePainter({
    required this.colors,
    required this.kind,
    required this.isHit,
    required this.pop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final holeCenter = Offset(size.width / 2, size.height * 0.78);
    final holeRect = Rect.fromCenter(center: holeCenter, width: size.width * 0.72, height: size.height * 0.22);
    canvas.drawOval(holeRect, Paint()..color = colors.hole);

    final kind = this.kind;
    if (kind == null || pop <= 0) return;

    final radius = min(size.width, size.height) * 0.28;
    final hiddenY = holeCenter.dy + radius * 1.4;
    final upY = holeCenter.dy - radius * 1.3;
    final center = Offset(size.width / 2, hiddenY + (upY - hiddenY) * pop);

    canvas.save();
    // Only the part above the hole and inside its opening is visible: the target comes out of the hole
    canvas.clipPath(
      Path()
        ..addRect(Rect.fromLTRB(0, 0, size.width, holeCenter.dy))
        ..addOval(holeRect),
    );
    canvas.translate(center.dx, center.dy);
    final scale = 0.7 + 0.3 * pop;
    canvas.scale(scale, scale);
    switch (kind) {
      case WhackTargetKind.critter:
        _paintCritter(canvas, radius);
      case WhackTargetKind.decoy:
        _paintDecoy(canvas, radius);
    }
    canvas.restore();
  }

  /// Friendly round critter with ears, eyes and a smile
  void _paintCritter(Canvas canvas, double r) {
    final body = Paint()..color = colors.critter;
    canvas
      ..drawCircle(Offset(-0.62 * r, -0.72 * r), 0.32 * r, body)
      ..drawCircle(Offset(0.62 * r, -0.72 * r), 0.32 * r, body)
      ..drawCircle(Offset.zero, r, body);

    final face = Paint()..color = colors.critterFace;
    final stroke = Paint()
      ..color = colors.critterFace
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.1 * r
      ..strokeCap = StrokeCap.round;
    if (isHit) {
      // Squeezed eyes: > <
      for (final side in const [-1.0, 1.0]) {
        final x = side * 0.36 * r;
        final tip = Offset(x - side * 0.12 * r, -0.18 * r);
        canvas
          ..drawLine(Offset(x + side * 0.12 * r, -0.3 * r), tip, stroke)
          ..drawLine(tip, Offset(x + side * 0.12 * r, -0.06 * r), stroke);
      }
    } else {
      canvas
        ..drawCircle(Offset(-0.36 * r, -0.18 * r), 0.13 * r, face)
        ..drawCircle(Offset(0.36 * r, -0.18 * r), 0.13 * r, face);
    }
    canvas.drawArc(Rect.fromCenter(center: Offset(0, 0.2 * r), width: 0.7 * r, height: 0.45 * r), 0.15 * pi, 0.7 * pi, false, stroke);
  }

  /// Spiky ball with an angry face: clearly a different shape than the critter
  void _paintDecoy(Canvas canvas, double r) {
    const spikes = 12;
    final path = Path();
    for (var i = 0; i < spikes * 2; i++) {
      final angle = -pi / 2 + i * pi / spikes;
      final distance = i.isEven ? 1.1 * r : 0.78 * r;
      final point = Offset(cos(angle) * distance, sin(angle) * distance);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = colors.decoy);

    final face = Paint()..color = colors.decoyFace;
    final stroke = Paint()
      ..color = colors.decoyFace
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.1 * r
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Angry brows and eyes
    canvas
      ..drawLine(Offset(-0.52 * r, -0.4 * r), Offset(-0.14 * r, -0.22 * r), stroke)
      ..drawLine(Offset(0.52 * r, -0.4 * r), Offset(0.14 * r, -0.22 * r), stroke)
      ..drawCircle(Offset(-0.3 * r, -0.06 * r), 0.11 * r, face)
      ..drawCircle(Offset(0.3 * r, -0.06 * r), 0.11 * r, face);
    // Zigzag mouth
    final mouth = Path()..moveTo(-0.36 * r, 0.36 * r);
    for (var i = 1; i <= 4; i++) {
      mouth.lineTo(-0.36 * r + i * 0.18 * r, (i.isOdd ? 0.24 : 0.36) * r);
    }
    canvas.drawPath(mouth, stroke);
  }

  @override
  bool shouldRepaint(covariant _WhackHolePainter oldDelegate) => oldDelegate.colors != colors || oldDelegate.kind != kind || oldDelegate.isHit != isHit || oldDelegate.pop != pop;
}
