import 'dart:ui';

import 'package:flutter_mini_games/src/core/theme/game_theme.dart';

/// The two players of a game played on one device.
/// [bottom] holds the phone, [top] sits opposite and sees a rotated half.
enum DuelPlayer {
  bottom('Player 1'),
  top('Player 2');

  final String label;

  const DuelPlayer(this.label);

  DuelPlayer get opponent => this == bottom ? top : bottom;
}

/// Player colors, always taken from the core theme
extension DuelPlayerColors on CoreGameTheme {
  Color playerColor(DuelPlayer player) => player == DuelPlayer.bottom ? colors.primary : colors.secondary;

  Color onPlayerColor(DuelPlayer player) => player == DuelPlayer.bottom ? colors.onPrimary : colors.onSecondary;
}
