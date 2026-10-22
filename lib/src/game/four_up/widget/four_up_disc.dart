import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mini_games/src/core/duel/duel_player.dart';

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
