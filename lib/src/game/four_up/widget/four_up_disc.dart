import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';
import 'package:flutter_mini_games/src/game/four_up/style/four_up_theme.dart';

/// Paints the disc of a player: a solid disc with a pattern, so the players are told apart
/// without color too: a ring for [DuelPlayer.bottom], a cross for [DuelPlayer.top].
void paintFourUpDisc(
  Canvas canvas, {
  required Offset center,
  required double radius,
  required DuelPlayer player,
  required Color color,
  required Color patternColor,
  required double patternStrokeWidth,
}) {
  canvas.drawCircle(center, radius, Paint()..color = color);
  final pattern = Paint()
    ..color = patternColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = min(patternStrokeWidth, radius * 0.2);
  switch (player) {
    case DuelPlayer.bottom:
      canvas.drawCircle(center, radius * 0.5, pattern);
    case DuelPlayer.top:
      final arm = radius * 0.42;
      canvas
        ..drawLine(center.translate(-arm, -arm), center.translate(arm, arm), pattern)
        ..drawLine(center.translate(-arm, arm), center.translate(arm, -arm), pattern);
  }
}

/// A single disc, e.g. on the turn banners
class FourUpDisc extends StatelessWidget {
  final DuelPlayer player;
  final double size;

  const FourUpDisc({
    required this.player,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FourUpTheme.of(context);
    return CustomPaint(
      size: Size.square(size),
      painter: _DiscPainter(
        player: player,
        color: theme.colors.disc(player),
        patternColor: theme.colors.onDisc(player),
        patternStrokeWidth: theme.dimens.patternStrokeWidth,
      ),
    );
  }
}

class _DiscPainter extends CustomPainter {
  final DuelPlayer player;
  final Color color;
  final Color patternColor;
  final double patternStrokeWidth;

  const _DiscPainter({
    required this.player,
    required this.color,
    required this.patternColor,
    required this.patternStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintFourUpDisc(
      canvas,
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2,
      player: player,
      color: color,
      patternColor: patternColor,
      patternStrokeWidth: patternStrokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _DiscPainter oldDelegate) =>
      oldDelegate.player != player || oldDelegate.color != color || oldDelegate.patternColor != patternColor || oldDelegate.patternStrokeWidth != patternStrokeWidth;
}
