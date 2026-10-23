import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/core/widget/components/cached_text_painter.dart';
import 'package:flutter_mini_games/src/game/push/game/logic/push_game_controller.dart';
import 'package:flutter_mini_games/src/game/push/style/push_theme.dart';

/// Draws the ring and the discs, the ring (radius 1 in world units) fills the shortest side
class PushPainter extends CustomPainter {
  /// Space around the full ring in world units, so its edge and discs on it stay visible
  static const margin = 0.06;

  final PushGameController controller;
  final PushTheme theme;

  /// Player numbers on the discs, owned by the widget
  final Map<DuelPlayer, CachedTextPainter> labels;

  PushPainter({
    required this.controller,
    required this.theme,
    required this.labels,
  }) : super(repaint: controller.frame);

  /// Pixels per world unit
  static double scaleFor(Size size) => min(size.width, size.height) / 2 / (PushGameController.initialRingRadius + margin);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = theme.colors;
    final dimens = theme.dimens;
    final scale = scaleFor(size);
    final center = size.center(Offset.zero);
    Offset toCanvas(Offset world) => center + world * scale;

    canvas
      ..clipRect(Offset.zero & size)
      ..drawRect(Offset.zero & size, Paint()..color = colors.outside);

    final ringRadius = controller.ringRadius * scale;
    final ring = Path()..addOval(Rect.fromCircle(center: center, radius: ringRadius));
    canvas.drawPath(ring, Paint()..color = colors.ring);

    // Start lines behind each disc, clipped to the ring while it shrinks
    canvas
      ..save()
      ..clipPath(ring);
    final linePaint = Paint()
      ..color = colors.startLine
      ..strokeWidth = dimens.startLineWidth
      ..strokeCap = StrokeCap.round;
    const lineY = PushGameController.startDistance + PushGameController.discRadius + 0.05;
    const lineHalfWidth = PushGameController.discRadius * 1.4;
    for (final y in [lineY, -lineY]) {
      canvas.drawLine(toCanvas(const Offset(-lineHalfWidth, 0).translate(0, y)), toCanvas(const Offset(lineHalfWidth, 0).translate(0, y)), linePaint);
    }
    canvas.restore();

    canvas.drawCircle(
      center,
      ringRadius,
      Paint()
        ..color = colors.ringEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = dimens.ringEdgeWidth,
    );

    // Aim lines below the discs
    for (final player in DuelPlayer.values) {
      final aim = controller.holdAim(player);
      if (aim == null || !controller.isPlaying) continue;
      final position = controller.disc(player).position;
      final direction = controller.aimDirection(player, aim);
      canvas.drawLine(
        toCanvas(position),
        toCanvas(position + direction * (PushGameController.discRadius + dimens.aimLength)),
        Paint()
          ..color = colors.disc(player)
          ..strokeWidth = dimens.aimLineWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final player in DuelPlayer.values) {
      final position = toCanvas(controller.disc(player).position);
      canvas.drawCircle(position, PushGameController.discRadius * scale, Paint()..color = colors.disc(player));
      _paintLabel(canvas, position, player);
    }
  }

  /// Player number, upright for the player it belongs to
  void _paintLabel(Canvas canvas, Offset position, DuelPlayer player) {
    final painter = labels[player]!.layout(player == DuelPlayer.bottom ? '1' : '2', theme.textStyles.discLabel.copyWith(color: theme.colors.onDisc(player)));
    canvas
      ..save()
      ..translate(position.dx, position.dy);
    if (player == DuelPlayer.top) canvas.rotate(pi);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PushPainter oldDelegate) => oldDelegate.controller != controller || oldDelegate.theme != theme || oldDelegate.labels != labels;
}
